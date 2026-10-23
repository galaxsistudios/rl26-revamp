#!/usr/bin/env python3
"""
add_sound_bank.py - add a NEW playable sound (e.g. a team's walk-out song) to
the game: one Wwise bank holding one event, built from any audio file, and
appended to the blobset at sound/<name>.bnk (add_entries.py; undo with its
remove-all).

What the game does (verified 2026-10-23):
  - Banks are blobset entries at "sound/<bank name>.bnk" (lowercase), stored
    fully raw (main_c == main_u, no vram part).
  - Wwise object IDs for named things are FNV-1 32 of the lowercase name:
    fnv1_32("music_ace_candy_apple_red") == that bank's bank ID and event ID.
  - Lua can load any bank by name (soundManager:loadTransitionBank) and play
    its event (soundManager:postEvent(name, "DefaultObject") -> playing ID;
    stopEvent(id, fadeSeconds); isEventFinished(id)).
  - The licensed menu songs are one bank each (Wwise v150): BKHD, DIDX+DATA
    (the song embedded), and HIRC = Sound -> ActorMixer -> ActorMixer (music
    routing) + Play Action + Event. That bank is the template here.

The clone keeps the template's mixers (routing/volume) and rewrites:
  BKHD bank ID = fnv1_32(name); Event ID = fnv1_32(name); new Sound, Action
  and media IDs (derived from the name); the parent mixer's child list ->
  the new Sound; Sound codec -> PCM (plugin 0x00010001), because Wwise
  Vorbis needs Wwise's own encoder; Play action property 0x3A (transition
  time, int ms - seen on stock Play/Stop actions) = the fade-in.

Audio is converted with ffmpeg to 16-bit PCM in a Wwise-style .wem (RIFF,
fmt 0xFFFE extensible, cbSize 6, Wwise channel config e.g. 0x3102 stereo),
loudness-normalised (default -8 LUFS, -1 dBTP) so songs match. Loudness
beyond full scale comes from the Sound's Wwise Volume property (0x00, dB;
default +4), applied in Wwise's float mix.

Usage:
    python add_sound_bank.py add --name intro_song_nrl_broncos --audio broncos.ogg [--fade-in-ms 2000] [--loudness -8] [--volume-db 4] [--replace] [--confirm]
    python add_sound_bank.py inspect --name music_ace_candy_apple_red
"""

import argparse
import os
import struct
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import add_entries  # noqa: E402
import classify_entries as ce  # noqa: E402
import pack  # noqa: E402

TEMPLATE_BANK = "music_ace_candy_apple_red"
SAMPLE_RATE = 48000
CHANNELS = 2

PLUGIN_PCM = 0x00010001
PROP_VOLUME = 0x00
PROP_TRANSITION_TIME = 0x3A

# Defaults: every song normalised to the same loudness, then boosted in Wwise.
DEFAULT_LOUDNESS = -8.0
DEFAULT_VOLUME_DB = 4.0

HIRC_SOUND, HIRC_ACTION, HIRC_EVENT, HIRC_ACTOR_MIXER = 2, 3, 4, 7

# Wwise AkChannelConfig: numChannels | type << 8 | mask << 12 (type 1 = standard).
CHANNEL_CONFIG = {1: 0x4101, 2: 0x3102}


def fnv1_32(text):
    h = 0x811C9DC5
    for c in text.lower().encode("utf-8"):
        h = (h * 0x01000193) & 0xFFFFFFFF
        h ^= c
    return h


def bank_path(name):
    return f"sound/{name.lower()}.bnk"


def read_bank(name):
    ce.load_index(pack.BLOBSET_PATH)
    data, files_count, hash_off, _ = pack.read_index(pack.BLOBSET_PATH)
    idx = add_entries.find_entry(data, files_count, hash_off, bank_path(name))
    if idx is None:
        raise SystemExit(f"bank {bank_path(name)} not found")
    raw, _, _, _ = ce.read_blob_full(pack.BLOBSET_PATH, idx)
    return bytes(raw)


def sections(bank):
    out, off = [], 0
    while off + 8 <= len(bank):
        tag, size = bank[off:off + 4].decode("latin1"), struct.unpack_from("<I", bank, off + 4)[0]
        out.append((tag, bank[off + 8:off + 8 + size]))
        off += 8 + size
    return out


def hirc_objects(body):
    count = struct.unpack_from("<I", body, 0)[0]
    objs, p = [], 4
    for _ in range(count):
        kind, size = body[p], struct.unpack_from("<I", body, p + 1)[0]
        objs.append([kind, bytearray(body[p + 5:p + 5 + size])])
        p += 5 + size
    return objs


def pack_section(tag, body):
    return tag.encode("latin1") + struct.pack("<I", len(body)) + bytes(body)


def make_wem(audio_path, gain_db, loudness=None):
    cmd = ["ffmpeg", "-v", "error", "-i", audio_path, "-vn"]
    filters = []
    if loudness is not None:
        # EBU R128 normalisation with a -1 dBTP ceiling, so every song lands at the same level.
        filters.append(f"loudnorm=I={loudness}:TP=-1.0:LRA=11")
    if gain_db:
        filters.append(f"volume={gain_db}dB")
    if filters:
        cmd += ["-af", ",".join(filters)]
    cmd += ["-ac", str(CHANNELS), "-ar", str(SAMPLE_RATE), "-f", "s16le", "-acodec", "pcm_s16le", "-"]
    pcm = subprocess.run(cmd, capture_output=True, check=True).stdout
    block = CHANNELS * 2
    fmt = struct.pack("<HHIIHHHHI", 0xFFFE, CHANNELS, SAMPLE_RATE, SAMPLE_RATE * block, block, 16,
                      6, 16, CHANNEL_CONFIG[CHANNELS])
    body = b"WAVE" + b"fmt " + struct.pack("<I", len(fmt)) + fmt + b"data" + struct.pack("<I", len(pcm)) + pcm
    seconds = len(pcm) / (SAMPLE_RATE * block)
    return b"RIFF" + struct.pack("<I", len(body)) + body, seconds


def build_bank(name, wem, fade_in_ms, volume_db=0.0):
    template = sections(read_bank(TEMPLATE_BANK))
    tags = [t for t, _ in template]
    if tags != ["BKHD", "DIDX", "DATA", "HIRC"]:
        raise SystemExit(f"template bank layout changed: {tags}")
    secs = dict(template)
    objs = hirc_objects(secs["HIRC"])
    kinds = [k for k, _ in objs]
    if kinds != [HIRC_SOUND, HIRC_ACTOR_MIXER, HIRC_ACTOR_MIXER, HIRC_ACTION, HIRC_EVENT]:
        raise SystemExit(f"template HIRC layout changed: {kinds}")

    bank_id = fnv1_32(name)
    sound_id = fnv1_32(name + "/sound")
    action_id = fnv1_32(name + "/action")
    media_id = fnv1_32(name + "/media")

    bkhd = bytearray(secs["BKHD"])
    struct.pack_into("<I", bkhd, 4, bank_id)

    sound = objs[0][1]
    old_sound_id = struct.unpack_from("<I", sound, 0)[0]
    struct.pack_into("<I", sound, 0, sound_id)
    struct.pack_into("<I", sound, 4, PLUGIN_PCM)
    if sound[8] != 0:
        raise SystemExit("template sound isn't an embedded (in-bank) source")
    struct.pack_into("<II", sound, 9, media_id, len(wem))
    if volume_db:
        # Node prop bundle at 31: cProps, ids[], float values[] (template: 1 prop, 0x22 = 2.0).
        # Prepend Volume (0x00, dB); Wwise mixes in float, so positive values add gain
        # beyond what the 16-bit file can hold.
        if sound[31] != 1 or sound[32] != 0x22:
            raise SystemExit("template sound prop bundle changed")
        other = bytes(sound[33:37])
        sound[31:37] = bytes([2, PROP_VOLUME, 0x22]) + struct.pack("<f", volume_db) + other

    mixer = objs[1][1]
    count, child = struct.unpack_from("<II", mixer, len(mixer) - 8)
    if count != 1 or child != old_sound_id:
        raise SystemExit("template mixer child list isn't [sound]")
    struct.pack_into("<I", mixer, len(mixer) - 4, sound_id)

    action = objs[3][1]
    if struct.unpack_from("<H", action, 4)[0] != 0x0403 or action[11] != 0:
        raise SystemExit("template action isn't a property-less Play")
    struct.pack_into("<I", action, 0, action_id)
    struct.pack_into("<I", action, 6, sound_id)
    struct.pack_into("<I", action, len(action) - 8, bank_id)
    if fade_in_ms:
        action[11:12] = bytes([1, PROP_TRANSITION_TIME]) + struct.pack("<i", fade_in_ms)

    event = objs[4][1]
    if event[4] != 1:
        raise SystemExit("template event doesn't have exactly one action")
    struct.pack_into("<I", event, 0, bank_id)
    struct.pack_into("<I", event, 5, action_id)

    hirc = struct.pack("<I", len(objs)) + b"".join(
        bytes([kind]) + struct.pack("<I", len(body)) + bytes(body) for kind, body in objs)
    didx = struct.pack("<III", media_id, 0, len(wem))
    return (pack_section("BKHD", bkhd) + pack_section("DIDX", didx) + pack_section("DATA", wem)
            + pack_section("HIRC", hirc))


def cmd_add(args):
    name = args.name.lower()
    loudness = None if args.no_normalize else args.loudness
    wem, seconds = make_wem(args.audio, args.gain_db, loudness)
    bank = build_bank(name, wem, args.fade_in_ms, args.volume_db)
    print(f"{name}: {seconds:.1f}s PCM {SAMPLE_RATE}Hz x{CHANNELS}, bank {len(bank)} bytes, "
          f"bank/event id 0x{fnv1_32(name):08x}, fade-in {args.fade_in_ms}ms, "
          f"loudness {loudness if loudness is not None else 'as-is'} LUFS, Wwise volume {args.volume_db:+g} dB")
    add_entries.add_entry(pack.BLOBSET_PATH, bank_path(name), bank, (len(bank), len(bank), 0, 0),
                          os.path.basename(args.audio), args.confirm, replace=args.replace)
    if not args.confirm:
        print("dry run - pass --confirm to write (close the game first)")


HIRC_NAMES = {HIRC_SOUND: "Sound", HIRC_ACTION: "Action", HIRC_EVENT: "Event", HIRC_ACTOR_MIXER: "ActorMixer"}


def cmd_inspect(args):
    bank = read_bank(args.name)
    for tag, body in sections(bank):
        print(f"{tag} {len(body)}")
        if tag == "HIRC":
            for kind, obj in hirc_objects(body):
                print(f"  {HIRC_NAMES.get(kind, kind)} id=0x{struct.unpack_from('<I', obj, 0)[0]:08x} size={len(obj)}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("add")
    p.add_argument("--name", required=True, help="bank + event name, e.g. intro_song_nrl_broncos")
    p.add_argument("--audio", required=True, help="any audio ffmpeg can read")
    p.add_argument("--fade-in-ms", type=int, default=2000)
    p.add_argument("--gain-db", type=float, default=0.0, help="extra file gain after normalising")
    p.add_argument("--loudness", type=float, default=DEFAULT_LOUDNESS, help="normalise to this integrated LUFS (true peak -1 dB)")
    p.add_argument("--no-normalize", action="store_true", help="keep the file's own level")
    p.add_argument("--volume-db", type=float, default=DEFAULT_VOLUME_DB, help="Wwise Sound volume (dB), applied in the mix")
    p.add_argument("--replace", action="store_true", help="overwrite a bank this tool added before")
    p.add_argument("--confirm", action="store_true", help="required to actually write")
    p.set_defaults(func=cmd_add)
    p = sub.add_parser("inspect")
    p.add_argument("--name", required=True)
    p.set_defaults(func=cmd_inspect)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())
