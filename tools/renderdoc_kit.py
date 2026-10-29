"""Get a jersey's composited textures out of the game with RenderDoc.

The game composites each kit (design, colours, decals) into col_map render
targets for the player model: top 4096x2048, shorts 2048x2048, socks
1024x1024. Reading them back from Lua doesn't work (every texture came back
as zeros or stale data), so this captures a frame with RenderDoc and saves
those render targets from the capture.

    python tools/renderdoc_kit.py launch
        Starts rugbyleague1.exe under RenderDoc (D3D11). In game, open a club's
        Uniforms list (FanHub too), highlight the jersey, press LB (writes
        Documents/RL26Jersey_<club>_<kit>.json with the design items), then
        press F12 to capture the frame. Quit when done.

    python tools/renderdoc_kit.py extract [capture.rdc] [--export RL26Jersey_x.json]
        Newest capture and newest export JSON by default. Saves the capture's
        kit-sized render targets, picks the top / shorts / socks colour maps,
        and writes RL26Jersey_<club>_<kit>_{top,shorts,socks}.png next to the
        JSON, ready for tools/fanhub_kit_import.py. --top/--shorts/--socks
        <resource id> override the pick.

The extraction runs inside RenderDoc's UI (qrenderdoc --python), which carries
the renderdoc Python module; nothing extra needs installing.
"""
import argparse
import glob
import json
import os
import shutil
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RENDERDOC = r"C:\Program Files\RenderDoc"
GAME = r"D:\SteamLibrary\steamapps\common\Rugby League"
CAPTURES = os.path.join(REPO, "_captures")
DOCUMENTS = os.path.join(os.environ.get("USERPROFILE", ""), "Documents")
# part: (texture size, name hints for the composited colour map)
PARTS = {
    "top": ((4096, 2048), ("top col",)),
    "shorts": ((2048, 2048), ("bottom col",)),
    "socks": ((1024, 1024), ("socks col",)),
}

# runs inside qrenderdoc (Python 3.8 + the renderdoc module)
INNER = r'''
import json, os, re, traceback
import renderdoc as rd

job = json.load(open(os.environ["RL26_RDC_JOB"]))
log = open(job["log"], "w")


def ok(result):
    if hasattr(result, "OK"):
        return result.OK()
    return result == rd.ResultCode.Succeeded


try:
    cap = rd.OpenCaptureFile()
    if not ok(cap.OpenFile(job["capture"], "", None)):
        raise RuntimeError("can't open " + job["capture"])
    result, ctrl = cap.OpenCapture(rd.ReplayOptions(), None)
    if not ok(result):
        raise RuntimeError("can't replay the capture: %s" % result)
    names = {str(r.resourceId): r.name for r in ctrl.GetResources()}
    sizes = set(tuple(s) for s in job["sizes"])
    writable = int(rd.TextureCategory.ColorTarget) | int(rd.TextureCategory.ShaderReadWrite)
    index = []
    for t in ctrl.GetTextures():
        rid = str(t.resourceId)
        entry = {"id": re.sub(r"\D", "", rid), "name": names.get(rid, ""), "width": t.width,
                 "height": t.height, "format": t.format.Name(), "flags": int(t.creationFlags),
                 "mips": t.mips, "arraysize": t.arraysize, "samples": t.msSamp}
        index.append(entry)
        if (t.width, t.height) not in sizes or t.arraysize != 1 or t.msSamp != 1:
            continue
        if not job["all"] and not int(t.creationFlags) & writable:
            continue
        save = rd.TextureSave()
        save.resourceId = t.resourceId
        save.destType = rd.FileType.PNG
        save.mip = 0
        save.alpha = rd.AlphaMapping.Discard
        path = os.path.join(job["out"], "%s_%dx%d.png" % (entry["id"], t.width, t.height))
        if ok(ctrl.SaveTexture(save, path)):
            entry["saved"] = path
        log.write("%s %s %dx%d %s flags %d -> %s\n" % (entry["id"], entry["name"], t.width, t.height,
                                                      entry["format"], entry["flags"], entry.get("saved")))
    json.dump(index, open(job["index"], "w"), indent=1)
    ctrl.Shutdown()
    cap.Shutdown()
    log.write("done\n")
except Exception:
    log.write(traceback.format_exc())
log.close()
os._exit(0)
'''


def newest(pattern):
    files = glob.glob(pattern)
    return max(files, key=os.path.getmtime) if files else None


def cmd_launch(args):
    os.makedirs(CAPTURES, exist_ok=True)
    exe = os.path.join(GAME, "rugbyleague1.exe")
    cmd = [os.path.join(RENDERDOC, "renderdoccmd.exe"), "capture", "-w", "-d", GAME,
           "-c", os.path.join(CAPTURES, "rl26"), exe]
    print("starting the game under RenderDoc: highlight the jersey, LB, then F12 to capture")
    subprocess.run(cmd)
    print("newest capture:", newest(os.path.join(CAPTURES, "*.rdc")))


def run_inner(capture, out, save_all):
    job = {"capture": capture, "out": out, "log": os.path.join(out, "renderdoc_log.txt"),
           "index": os.path.join(out, "textures.json"), "all": save_all,
           "sizes": [size for size, _ in PARTS.values()]}
    with open(os.path.join(out, "job.json"), "w") as f:
        json.dump(job, f)
    script = os.path.join(out, "inner.py")
    with open(script, "w") as f:
        f.write(INNER)
    env = dict(os.environ, RL26_RDC_JOB=os.path.join(out, "job.json"))
    subprocess.run([os.path.join(RENDERDOC, "qrenderdoc.exe"), "--python", script], env=env, timeout=1800)
    log = open(job["log"]).read() if os.path.exists(job["log"]) else "(no log)"
    if not os.path.exists(job["index"]):
        raise SystemExit("RenderDoc didn't finish:\n" + log)
    return json.load(open(job["index"]))


def pick(index, part, override):
    size, hints = PARTS[part]
    saved = [t for t in index if t.get("saved") and (t["width"], t["height"]) == size]
    if override:
        match = [t for t in saved if t["id"] == str(override)]
        if not match:
            raise SystemExit(f"{part}: resource {override} isn't among the saved {size[0]}x{size[1]} textures")
        return match[0], saved
    named = [t for t in saved if any(h in t["name"].lower() for h in hints)]
    if len(named) == 1:
        return named[0], saved
    if len(saved) == 1:
        return saved[0], saved
    return None, saved


def cmd_extract(args):
    capture = args.capture or newest(os.path.join(CAPTURES, "*.rdc"))
    if not capture:
        raise SystemExit(f"no capture given and none in {CAPTURES}")
    export = args.export or newest(os.path.join(DOCUMENTS, "RL26Jersey_*.json"))
    if not export:
        raise SystemExit("no RL26Jersey_*.json export (press LB on the jersey in game first)")
    out = args.out or os.path.join(CAPTURES, os.path.splitext(os.path.basename(capture))[0])
    os.makedirs(out, exist_ok=True)
    print(f"capture {capture}\nexport  {export}\nsaving render targets to {out} ...")
    index = run_inner(capture, out, args.all)

    base = export[:-len(".json")]
    missing = []
    for part in PARTS:
        chosen, saved = pick(index, part, getattr(args, part))
        if chosen is None:
            missing.append(part)
            print(f"\n{part}: {len(saved)} candidates - rerun with --{part} <id>:")
            for t in saved:
                print(f"  {t['id']:>8}  {t['format']:<24} {t['name'] or '(no name)'}  {t['saved']}")
            continue
        shutil.copyfile(chosen["saved"], f"{base}_{part}.png")
        print(f"{part}: resource {chosen['id']} {chosen['name'] or ''} ({chosen['format']}) -> {base}_{part}.png")
    if missing:
        raise SystemExit(f"\npick {', '.join(missing)} by id (look at the PNGs in {out})")
    print(f"\nnext: python tools/fanhub_kit_import.py \"{export}\" --name <name> [--club <id> --kit-name \"NAME\"]")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("launch", help="start the game under RenderDoc")
    p = sub.add_parser("extract", help="save the jersey textures from a capture")
    p.add_argument("capture", nargs="?")
    p.add_argument("--export", help="the RL26Jersey_*.json from LB (default: newest in Documents)")
    p.add_argument("--out", help="folder for the saved render targets (default: _captures/<capture>)")
    p.add_argument("--all", action="store_true", help="save every kit-sized texture, not only render targets")
    for part in PARTS:
        p.add_argument(f"--{part}", help=f"resource id of the {part} colour map")
    args = ap.parse_args()
    {"launch": cmd_launch, "extract": cmd_extract}[args.cmd](args)


if __name__ == "__main__":
    main()
