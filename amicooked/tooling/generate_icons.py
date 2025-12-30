"""
Generate consistent Android + iOS launcher icons from a single source image.

Why:
- If some icon assets have transparency and others don't, platforms may render
  white (or other) backgrounds inconsistently.

Usage (from repo root):
  python amicooked/tooling/generate_icons.py

Notes:
- Uses iOS 1024x1024 AppIcon as the default source if present.
- Composites any transparency over a black background to ensure a black icon bg.
"""

from __future__ import annotations

import json
from pathlib import Path


def _require_pillow():
    try:
        from PIL import Image  # type: ignore

        return Image
    except Exception as e:  # pragma: no cover
        raise SystemExit(
            "Pillow is required. Install it with: pip install pillow\n"
            f"Import error: {e}"
        )


def _composite_on_black(img):
    Image = _require_pillow()
    img = img.convert("RGBA")
    bg = Image.new("RGBA", img.size, (0, 0, 0, 255))
    bg.alpha_composite(img)
    return bg


def _resize_square(img, px: int):
    Image = _require_pillow()
    return img.resize((px, px), resample=Image.Resampling.LANCZOS)


def _write_png(img, path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    # Force opaque output to prevent platforms from "filling" transparency.
    img = img.convert("RGB")
    img.save(path, format="PNG", optimize=True)


def generate_ios_app_icons(project_root: Path, src_img):
    appicon_dir = (
        project_root / "amicooked" / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    )
    contents_path = appicon_dir / "Contents.json"
    if not contents_path.exists():
        return 0

    contents = json.loads(contents_path.read_text(encoding="utf-8"))
    images = contents.get("images", [])
    count = 0
    for entry in images:
        filename = entry.get("filename")
        size = entry.get("size")
        scale = entry.get("scale")
        if not filename or not size or not scale:
            continue

        # size like "20x20", scale like "2x"
        base = float(size.split("x")[0])
        mult = float(scale.replace("x", ""))
        px = int(round(base * mult))

        out_path = appicon_dir / filename
        out_img = _resize_square(src_img, px)
        _write_png(out_img, out_path)
        count += 1

    return count


def generate_android_mipmap_icons(project_root: Path, src_img):
    res_dir = project_root / "amicooked" / "android" / "app" / "src" / "main" / "res"

    # Standard launcher icon sizes (px)
    targets = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }

    count = 0
    for folder, px in targets.items():
        out_path = res_dir / folder / "ic_launcher.png"
        out_img = _resize_square(src_img, px)
        _write_png(out_img, out_path)
        count += 1

    return count


def main():
    Image = _require_pillow()

    project_root = Path(__file__).resolve().parents[2]

    default_src = (
        project_root
        / "amicooked"
        / "ios"
        / "Runner"
        / "Assets.xcassets"
        / "AppIcon.appiconset"
        / "Icon-App-1024x1024@1x.png"
    )
    if not default_src.exists():
        raise SystemExit(
            "Could not find default source icon:\n"
            f"  {default_src}\n"
            "Create/choose a 1024x1024 PNG with a BLACK background and rerun."
        )

    src = Image.open(default_src)
    src = _composite_on_black(src)

    ios_n = generate_ios_app_icons(project_root, src)
    and_n = generate_android_mipmap_icons(project_root, src)

    print(f"Generated iOS AppIcon images: {ios_n}")
    print(f"Generated Android mipmap icons: {and_n}")
    print("Done.")


if __name__ == "__main__":
    main()


