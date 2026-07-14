#!/usr/bin/env python3
"""
Gera guará + equipamentos com encaixe calibrado.

Estratégia:
1. Personagem high-res no canvas 400x560, torso alinhado.
2. Peças da folha escaladas por largura-alvo (não pelo fator do fox high-res).
3. Âncora visual (abertura dourada / colarinho / viseira) mapeada para
   o centro da cabeça e o queixo do guará.
4. Interiores pretos (pescoço/axilas) viram transparentes para o base aparecer.
"""

from __future__ import annotations

from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "RotinaPlus" / "Resources" / "Assets.xcassets"
SOURCE_DIR = ROOT / "RotinaPlus" / "Resources" / "ArtSource"
SCRIPTS = Path(__file__).resolve().parent

FOX_REPO = SOURCE_DIR / "guara_default.png"
FOX_USER = Path(
    "/Users/dev/.cursor/projects/Users-dev-Documents-GitHub-rotinaplus/assets/"
    "image-9f934e6e-e536-4915-9eb8-49bbaf55b9b6.png"
)
EQUIP_USER = Path(
    "/Users/dev/.cursor/projects/Users-dev-Documents-GitHub-rotinaplus/assets/"
    "image-4ed8d82b-b489-4be9-b9fe-82454c05ff74.png"
)
EQUIP_REPO = SOURCE_DIR / "conjuntos_equipamento.png"

CANVAS_W, CANVAS_H = 400, 560
CHAR_H = 500
T = (0, 0, 0, 0)
BODY_X = 248


def blank() -> Image.Image:
    return Image.new("RGBA", (CANVAS_W, CANVAS_H), T)


def is_checker(p):
    r, g, b, a = p
    if a < 10:
        return True
    if abs(r - g) < 16 and abs(g - b) < 16 and r >= 140:
        return True
    return False


def clear_checker(im: Image.Image) -> Image.Image:
    im = im.convert("RGBA")
    px = im.load()
    w, h = im.size
    for y in range(h):
        for x in range(w):
            if is_checker(px[x, y]):
                px[x, y] = T
    return im


def trim(im: Image.Image, pad: int = 4) -> Image.Image:
    bbox = im.getbbox()
    if not bbox:
        return im
    x0, y0, x1, y1 = bbox
    return im.crop(
        (max(0, x0 - pad), max(0, y0 - pad), min(im.size[0], x1 + pad), min(im.size[1], y1 + pad))
    )


def clean_fox(src: Path) -> Image.Image:
    im = clear_checker(Image.open(src))
    px = im.load()
    w, h = im.size
    visited = [[False] * w for _ in range(h)]
    q = deque()
    for x in range(w):
        q.append((x, 0))
        q.append((x, h - 1))
    for y in range(h):
        q.append((0, y))
        q.append((w - 1, y))
    while q:
        x, y = q.popleft()
        if x < 0 or y < 0 or x >= w or y >= h or visited[y][x]:
            continue
        visited[y][x] = True
        if px[x, y][3] > 0 and not is_checker(px[x, y]):
            continue
        px[x, y] = T
        q.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    for y in range(h):
        for x in range(w):
            if is_checker(px[x, y]):
                px[x, y] = T
    return trim(im, 8)


def extract_components(src: Path) -> list[dict]:
    im = clear_checker(Image.open(src))
    px = im.load()
    w, h = im.size
    visited = [[False] * w for _ in range(h)]
    comps = []

    def bfs(sx, sy):
        q = deque([(sx, sy)])
        visited[sy][sx] = True
        cells = []
        while q:
            x, y = q.popleft()
            cells.append((x, y))
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if 0 <= nx < w and 0 <= ny < h and not visited[ny][nx] and px[nx, ny][3] > 0:
                    visited[ny][nx] = True
                    q.append((nx, ny))
        return cells

    for y in range(h):
        for x in range(w):
            if not visited[y][x] and px[x, y][3] > 0:
                cells = bfs(x, y)
                if len(cells) < 500:
                    continue
                xs = [c[0] for c in cells]
                ys = [c[1] for c in cells]
                x0, y0, x1, y1 = min(xs), min(ys), max(xs) + 1, max(ys) + 1
                if x1 - x0 < 20:
                    continue
                piece = Image.new("RGBA", (x1 - x0, y1 - y0), T)
                pp = piece.load()
                for cx, cy in cells:
                    pp[cx - x0, cy - y0] = px[cx, cy]
                comps.append(
                    {
                        "img": trim(piece),
                        "cx": sum(xs) / len(xs),
                        "cy": sum(ys) / len(ys),
                        "n": len(cells),
                        "wh": (x1 - x0, y1 - y0),
                    }
                )
    comps.sort(key=lambda c: (c["cy"], c["cx"]))
    return comps


def align_fox_to_body_x(fox: Image.Image, scale: float) -> Image.Image:
    nw = max(1, int(fox.size[0] * scale))
    nh = max(1, int(fox.size[1] * scale))
    scaled = fox.resize((nw, nh), Image.NEAREST)
    x0 = (CANVAS_W - nw) // 2
    y0 = CANVAS_H - nh - 20
    canvas = Image.new("RGBA", (CANVAS_W, CANVAS_H), T)
    canvas.alpha_composite(scaled, (x0, y0))

    px = canvas.load()
    xs = [x for y in range(200, 340) for x in range(140, 360) if px[x, y][3] > 200]
    if xs:
        shift = int(round(BODY_X - sum(xs) / len(xs)))
        canvas2 = Image.new("RGBA", (CANVAS_W, CANVAS_H), T)
        canvas2.alpha_composite(scaled, (x0 + shift, y0))
        return canvas2
    return canvas


def compose(*layers: Image.Image) -> Image.Image:
    out = blank()
    for layer in layers:
        out.alpha_composite(layer)
    return out


def write_imageset(name: str, img: Image.Image):
    folder = ASSETS / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    img.save(folder / f"{name}.png")
    (folder / "Contents.json").write_text(
        f"""{{
  "images" : [
    {{ "filename" : "{name}.png", "idiom" : "universal", "scale" : "1x" }},
    {{ "idiom" : "universal", "scale" : "2x" }},
    {{ "idiom" : "universal", "scale" : "3x" }}
  ],
  "info" : {{ "author" : "xcode", "version" : 1 }}
}}
"""
    )


def classify_equipment(comps: list[dict]) -> dict:
    refs = [c for c in comps if c["cx"] < 350 and c["n"] > 40000]
    sheet_fox_h = max(c["wh"][1] for c in refs) if refs else 450

    items = [
        c
        for c in comps
        if c["cx"] > 380 and c["wh"][1] >= 70 and c["wh"][0] < 400 and c["n"] > 1500
    ]
    couro = sorted([c for c in items if 150 < c["cy"] < 280], key=lambda c: -c["n"])
    placas = sorted([c for c in items if 400 < c["cy"] < 560], key=lambda c: -c["n"])
    robes_row = sorted([c for c in items if c["cy"] > 650], key=lambda c: c["cx"])

    peitoral_couro = couro[0]["img"]
    rest_c = sorted(couro[1:], key=lambda c: c["cx"])
    luvas = [c["img"] for c in rest_c if c["cx"] < 820]
    botas = [c["img"] for c in rest_c if c["cx"] >= 820]

    peitoral_placas = placas[0]["img"]
    rest_p = sorted(placas[1:], key=lambda c: c["cx"])
    ombreiras, capacete, grevas = [], None, None
    for c in rest_p:
        if c["n"] < 4000:
            ombreiras.append(c["img"])
        elif c["cx"] > 880:
            grevas = c["img"]
        else:
            capacete = c["img"]

    robes_body = max(robes_row, key=lambda c: c["n"])["img"]
    hood_candidates = [c for c in robes_row if c["img"] is not robes_body]
    capuz = hood_candidates[0]["img"] if hood_candidates else robes_body

    return {
        "sheet_fox_h": sheet_fox_h,
        "peitoralCouro": peitoral_couro,
        "peitoralPlacas": peitoral_placas,
        "robes": robes_body,
        "capacete": capacete or peitoral_placas,
        "capuz": capuz,
        "luvas": luvas,
        "botas": botas,
        "ombreiras": ombreiras,
        "grevas": grevas or peitoral_placas,
    }


def clear_black_holes(im: Image.Image, thresh: int = 55) -> Image.Image:
    """Interiores pretos (pescoço/axilas) → transparentes; preserva contorno."""
    a = np.array(im)
    dark = (a[:, :, 3] > 0) & (a[:, :, 0].astype(int) + a[:, :, 1] + a[:, :, 2] < thresh)
    h, w = dark.shape
    keep = np.zeros_like(dark)
    ys, xs = np.where(dark)
    for y, x in zip(ys, xs):
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if ny < 0 or nx < 0 or ny >= h or nx >= w or a[ny, nx, 3] < 40:
                keep[y, x] = True
                break
    a[dark & ~keep, 3] = 0
    return Image.fromarray(a)


def place_feature(piece: Image.Image, canvas_xy, feature_xy, target_w: float) -> Image.Image:
    s = target_w / piece.size[0]
    nw = max(1, int(round(piece.size[0] * s)))
    nh = max(1, int(round(piece.size[1] * s)))
    sc = piece.resize((nw, nh), Image.NEAREST)
    ax, ay = canvas_xy
    fx, fy = feature_xy
    c = blank()
    c.alpha_composite(sc, (int(round(ax - fx * s)), int(round(ay - fy * s))))
    return c


def place_center(piece: Image.Image, cx: float, cy: float, tw: float) -> Image.Image:
    s = tw / piece.size[0]
    nw = max(1, int(round(piece.size[0] * s)))
    nh = max(1, int(round(piece.size[1] * s)))
    sc = piece.resize((nw, nh), Image.NEAREST)
    a = np.array(sc)
    m = a[:, :, 3] > 200
    yy, xx = np.where(m)
    if len(xx) == 0:
        return blank()
    c = blank()
    c.alpha_composite(sc, (int(round(cx - xx.mean())), int(round(cy - yy.mean()))))
    return c


def robe_opening(im: Image.Image) -> tuple[float, float]:
    a = np.array(im)
    w, h = im.size
    gold = (
        (a[:, :, 3] > 200)
        & (a[:, :, 0] > 160)
        & (a[:, :, 1] > 120)
        & (a[:, :, 2] < 100)
        & (a[:, :, 0] > a[:, :, 2] + 40)
    )
    mid = gold[int(h * 0.12) : int(h * 0.55), :]
    colsum = mid.sum(axis=0)
    if colsum.max() == 0:
        return w / 2, 20.0
    peaks = np.where(colsum > colsum.max() * 0.35)[0]
    if len(peaks) >= 2:
        gaps = np.diff(peaks)
        if gaps.max() > 3:
            i = int(np.argmax(gaps))
            ox = (peaks[i] + peaks[i + 1]) / 2
        else:
            ox = float(peaks.mean())
    else:
        ox = w / 2
    for y in range(h):
        if gold[y, max(0, int(ox) - 15) : int(ox) + 15].any():
            return float(ox), float(y)
    return float(ox), 20.0


def place_top_feature(
    piece: Image.Image, canvas_cx: float, top_y: float, feature_x: float, target_w: float
) -> Image.Image:
    """Topo do conteúdo em top_y; feature_x (abertura) alinhada a canvas_cx."""
    s = target_w / piece.size[0]
    nw = max(1, int(round(piece.size[0] * s)))
    nh = max(1, int(round(piece.size[1] * s)))
    sc = piece.resize((nw, nh), Image.NEAREST)
    a = np.array(sc)
    rows = np.where((a[:, :, 3] > 40).any(axis=1))[0]
    ctop = int(rows[0]) if len(rows) else 0
    c = blank()
    c.alpha_composite(
        sc, (int(round(canvas_cx - feature_x * s)), int(round(top_y - ctop)))
    )
    return c


def extract_head_layer(base: Image.Image, anat: dict) -> Image.Image:
    """Extrai o rosto/cabeça para desenhar acima da roupa."""
    from collections import deque

    chin = anat["chin_y"]
    ba = np.array(base)
    ys = np.arange(CANVAS_H)[:, None]
    xs = np.arange(CANVAS_W)[None, :]
    r, g, b = ba[:, :, 0].astype(int), ba[:, :, 1].astype(int), ba[:, :, 2].astype(int)
    upper = (ba[:, :, 3] > 200) & (ys < chin + 8) & (xs > 160) & (xs < 340)
    is_fur = upper & (
        ((r > 180) & (g > 80) & (g < 200) & (b < 120))
        | ((r > 200) & (g > 180) & (b > 140))
        | ((r < 80) & (g < 80) & (b < 80))
        | ((r > 40) & (r < 120) & (g < 90) & (b < 80))
    )
    tight = (ba[:, :, 3] > 200) & (ys < chin - 2) & (xs > 175) & (xs < 330)
    head_mask = is_fur | tight
    visited = np.zeros((CANVAS_H, CANVAS_W), dtype=bool)
    q = deque()
    for y in range(40, 100):
        for x in range(220, 280):
            if head_mask[y, x]:
                q.append((y, x))
                break
        if q:
            break
    while q:
        y, x = q.popleft()
        if not (0 <= y < CANVAS_H and 0 <= x < CANVAS_W) or visited[y, x]:
            continue
        if not head_mask[y, x] or y > chin + 6:
            continue
        visited[y, x] = True
        q.extend(((y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1)))
    out = np.zeros_like(ba)
    out[visited] = ba[visited]
    return Image.fromarray(out)


def measure_anatomy(base: Image.Image):
    ba = np.array(base)
    body = ba[:, :, 3] > 200
    ys = np.arange(CANVAS_H)[:, None]
    xs = np.arange(CANVAS_W)[None, :]
    head = body & (ys < 165) & (xs > 180) & (xs < 330)
    hy, hx = np.where(head)
    head_cx, head_cy = float(hx.mean()), float(hy.mean())
    cream = (
        (ba[:, :, 3] > 200)
        & (ba[:, :, 0] > 200)
        & (ba[:, :, 1] > 185)
        & (ba[:, :, 2] > 150)
        & (ys >= 110)
        & (ys <= 175)
        & (xs >= 220)
        & (xs < 295)
    )
    cy, _ = np.where(cream)
    chin_y = int(cy.max())

    boots = body & (ys > 460) & (ba[:, :, 0] < 90) & (ba[:, :, 1] < 70)
    hands = body & (ys > 300) & (ys < 360) & (ba[:, :, 0] < 100) & (ba[:, :, 1] < 80)

    def centroid(mask):
        yy, xx = np.where(mask)
        return float(xx.mean()), float(yy.mean())

    flx, fly = centroid(boots & (xs < 240))
    frx, fry = centroid(boots & (xs >= 240))
    hlx, hly = centroid(hands & (xs < 210))
    hrx, hry = centroid(hands & (xs > 280))
    return {
        "head_cx": head_cx,
        "head_cy": head_cy,
        "chin_y": chin_y,
        "feet": (flx, fly, frx, fry),
        "hands": (hlx, hly, hrx, hry),
    }


def main():
    SOURCE_DIR.mkdir(parents=True, exist_ok=True)
    ASSETS.mkdir(parents=True, exist_ok=True)

    fox_src = FOX_USER if FOX_USER.exists() else FOX_REPO
    equip_src = EQUIP_USER if EQUIP_USER.exists() else EQUIP_REPO
    Image.open(fox_src).save(FOX_REPO)
    Image.open(equip_src).save(EQUIP_REPO)

    for old in ASSETS.glob("guara_*.imageset"):
        for f in old.iterdir():
            f.unlink()
        old.rmdir()
    (ASSETS / "Contents.json").write_text('{"info":{"author":"xcode","version":1}}\n')

    fox = clean_fox(fox_src)
    base = align_fox_to_body_x(fox, CHAR_H / fox.size[1])
    anat = measure_anatomy(base)
    head_cx, head_cy, chin_y = anat["head_cx"], anat["head_cy"], anat["chin_y"]
    flx, fly, frx, fry = anat["feet"]
    hlx, hly, hrx, hry = anat["hands"]

    eq = classify_equipment(extract_components(equip_src))
    robes = clear_black_holes(eq["robes"], 45)
    leather = clear_black_holes(eq["peitoralCouro"], 50)
    plate = clear_black_holes(eq["peitoralPlacas"], 55)
    helm = clear_black_holes(eq["capacete"], 40)
    rox, roy = robe_opening(robes)

    hood = eq["capuz"].crop((0, 0, eq["capuz"].size[0], int(eq["capuz"].size[1] * 0.50)))
    hood = clear_black_holes(hood, 45)

    layers = {
        "guara_base_m": base,
        "guara_base_f": base.copy(),
        # Paper-doll: roupa no pescoço; guara_head é desenhado por cima na UI
        "guara_head": extract_head_layer(base, anat),
        "guara_corpo_robes": place_top_feature(
            clear_black_holes(eq["robes"], 48), head_cx + 6, chin_y - 8, rox, 195
        ),
        "guara_corpo_peitoralCouro": place_top_feature(
            clear_black_holes(eq["peitoralCouro"], 55), head_cx + 6, chin_y - 6, 70.0, 165
        ),
        "guara_corpo_peitoralPlacas": place_top_feature(
            clear_black_holes(eq["peitoralPlacas"], 55), head_cx + 6, chin_y - 10, 80.0, 180
        ),
        "guara_cabeca_capacete": place_center(
            clear_black_holes(eq["capacete"], 40), head_cx + 4, head_cy + 4, 125
        ),
        "guara_cabeca_capuz": place_center(hood, head_cx + 2, head_cy - 2, 155),
        "guara_ombros_ombreiras": compose(
            place_center(eq["ombreiras"][0], head_cx - 50, chin_y + 20, 62)
            if eq["ombreiras"]
            else blank(),
            place_center(eq["ombreiras"][1], head_cx + 52, chin_y + 16, 56)
            if len(eq["ombreiras"]) > 1
            else blank(),
        ),
        "guara_maos_luvas": compose(
            place_center(eq["luvas"][0], hlx, hly, 55) if eq["luvas"] else blank(),
            place_center(eq["luvas"][1], hrx, hry, 55) if len(eq["luvas"]) > 1 else blank(),
        ),
        "guara_pes_botasCouro": compose(
            place_center(eq["botas"][0], flx, fly, 58) if eq["botas"] else blank(),
            place_center(eq["botas"][1], frx, fry, 60) if len(eq["botas"]) > 1 else blank(),
        ),
        "guara_pes_grevas": place_center(eq["grevas"], (flx + frx) / 2, min(fly, fry) - 5, 135),
    }

    head = layers["guara_head"]
    layers["guara_thumb_corpo_nenhum"] = compose(base, head)
    for k in ("peitoralCouro", "peitoralPlacas", "robes"):
        layers[f"guara_thumb_corpo_{k}"] = compose(base, layers[f"guara_corpo_{k}"], head)
    layers["guara_thumb_cabeca_nenhuma"] = compose(base, head)
    for k in ("capacete", "capuz"):
        layers[f"guara_thumb_cabeca_{k}"] = compose(base, head, layers[f"guara_cabeca_{k}"])
    layers["guara_thumb_ombros_nenhuma"] = compose(base, head)
    layers["guara_thumb_ombros_ombreiras"] = compose(base, layers["guara_ombros_ombreiras"], head)
    layers["guara_thumb_maos_nenhuma"] = compose(base, head)
    layers["guara_thumb_maos_luvas"] = compose(base, layers["guara_maos_luvas"], head)
    layers["guara_thumb_pes_nenhum"] = compose(base, head)
    for k in ("botasCouro", "grevas"):
        layers[f"guara_thumb_pes_{k}"] = compose(base, layers[f"guara_pes_{k}"], head)

    for name, img in layers.items():
        write_imageset(name, img)
        print("ok", name)

    compose(base, layers["guara_corpo_robes"], head).save(SCRIPTS / "_preview_robe.png")
    compose(
        base,
        layers["guara_corpo_peitoralPlacas"],
        layers["guara_ombros_ombreiras"],
        head,
        layers["guara_cabeca_capacete"],
        layers["guara_pes_grevas"],
    ).save(SCRIPTS / "_preview_plate.png")
    compose(
        base,
        layers["guara_corpo_peitoralCouro"],
        layers["guara_maos_luvas"],
        layers["guara_pes_botasCouro"],
        head,
    ).save(SCRIPTS / "_preview_leather.png")
    compose(base, layers["guara_corpo_robes"], head, layers["guara_cabeca_capuz"]).save(
        SCRIPTS / "_preview_hood.png"
    )
    print("head_cx", round(head_cx, 1), "chin_y", chin_y, "opening", round(rox, 1), round(roy, 1))


if __name__ == "__main__":
    main()
