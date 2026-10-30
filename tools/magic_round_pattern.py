"""Generate the NRL Magic Round staggered diagonal-stripe pattern.

The pattern is a row of vertical columns. Each column holds diagonal stripes
(rising left to right) alternating colour / black; neighbouring columns are
shifted vertically and cycle the palette from a different start, so stripes
never line up across a column edge.

Palette is sampled from the Magic Round Brisbane banner side borders.

  python tools/magic_round_pattern.py out.png --size 1920x1080 --columns 6
"""
import argparse
import random

from PIL import Image, ImageDraw

PALETTE = [
    "#00924A",  # green
    "#00C4FA",  # cyan
    "#F50004",  # red
    "#0020D8",  # blue
    "#62FF30",  # lime
    "#F37C00",  # orange
    "#4D277A",  # purple
    "#85004B",  # maroon
    "#F8D60A",  # yellow
    "#2C373D",  # slate
    "#4AAA22",  # grass green
]

# Rise of the stripes per pixel across (measured from the banner: 19px over 35px).
SLOPE = 0.54
SS = 4  # supersampling factor for smooth edges


def column_colours(rng, count, prev):
    """A palette cycle for one column. With shifted columns a stripe can touch
    the neighbouring column's stripes one index either side, so none of those
    may share its colour."""
    for _ in range(500):
        order = PALETTE[:]
        rng.shuffle(order)
        seq = [order[i % len(order)] for i in range(count)]
        if not prev or all(seq[i] not in prev[max(0, i - 1):i + 2] for i in range(count)):
            return seq
    return seq


def render(width, height, columns, period, gap, background, seed, offset):
    rng = random.Random(seed)
    W, H = width * SS, height * SS
    P = period * SS
    band = P * (1.0 - gap)
    col_w = W / columns
    rise = col_w * SLOPE
    img = Image.new("RGB", (W, H), background)
    draw = ImageDraw.Draw(img)

    count = int((H + rise) // P) + 3
    prev = None
    for c in range(columns):
        x0, x1 = c * col_w, (c + 1) * col_w
        if offset == "random":
            shift = rng.uniform(0, P)
        else:
            # Corner to corner: this column's stripe bottom-left meets the previous
            # column's stripe top-right, i.e. shift up by the rise plus one band.
            shift = (-c * (rise + band + offset * P)) % P
        colours = column_colours(rng, count, prev)
        prev = colours
        for i in range(count):
            # Stripe top edge at the column's left side; it rises by `rise` across.
            y = i * P - P + shift
            draw.polygon(
                [(x0, y), (x1, y - rise), (x1, y - rise + band), (x0, y + band)],
                fill=colours[i],
            )
    return img.resize((width, height), Image.LANCZOS)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("out")
    ap.add_argument("--size", default="1920x1080", help="WxH in pixels")
    ap.add_argument("--columns", type=int, default=6)
    ap.add_argument("--period", type=int, default=0, help="stripe repeat in px (default: auto from height)")
    ap.add_argument("--gap", type=float, default=0.5, help="black share of each period (0-0.9)")
    ap.add_argument("--offset", default="0",
                    help="extra column shift as a fraction of the period on top of corner-to-corner "
                         "(default 0), or 'random' for an independent shift per column")
    ap.add_argument("--background", default="#000000")
    ap.add_argument("--seed", type=int, default=26)
    a = ap.parse_args()

    w, h = (int(v) for v in a.size.lower().split("x"))
    period = a.period or max(8, round(h / 4.5))
    offset = a.offset if a.offset == "random" else float(a.offset)
    img = render(w, h, a.columns, period, a.gap, a.background, a.seed, offset)
    img.save(a.out)
    print(f"wrote {a.out} ({w}x{h}, {a.columns} columns, period {period}px, seed {a.seed})")


if __name__ == "__main__":
    main()
