"""Turn Meshy exports into life-size, floor-grounded pet models.

    python scripts/prepare_pet_models.py --env admin/.env --src ../meshy_raw --dst ../ar_models_normalized

Every <petname>.glb in --src (name = the pet's name in the database, any case) is
looked up in Supabase for its type and size, scaled to the standing height in
glb_tools.EXPECTED_HEIGHT_M, grounded (feet at y=0, centred), made non-metal and written to --dst.
Meshy models are static, so the idle-pose ratio is 1. Prints each file's size and
warns above 5 MB / fails above 8 MB. With --shrink, any input over 5 MB is first
reduced to ~30k triangles and 1024 px textures (needs Node; see shrink_glb.py).
"""
import argparse
import json
import os
import sys
import tempfile

from check_glb_scale import get, load_env, MAX_MB, WARN_MB
from glb_tools import expected_height, model_height, read_glb, write_glb
from normalize_glb import ground, normalize
from shrink_glb import shrink


def matte(gltf):
    """Make every material matte fur. Meshy leaves metallicFactor unset (glTF default 1),
    so a pet renders as dark chrome in dim AR light, and its roughness map is glossy
    (~0.4), so ceiling lights draw a white streak along the back."""
    for mat in gltf.get("materials", []):
        pbr = mat.setdefault("pbrMetallicRoughness", {})
        pbr["metallicFactor"] = 0.0
        pbr["roughnessFactor"] = 0.9
        pbr.pop("metallicRoughnessTexture", None)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--env", required=True)
    ap.add_argument("--src", required=True)
    ap.add_argument("--dst", required=True)
    ap.add_argument("--shrink", action="store_true",
                    help="reduce inputs over 5 MB to ~30k faces / 1024 px textures first")
    ap.add_argument("--pet", action="append", default=[], metavar="NAME:TYPE:SIZE",
                    help="pet not in the database yet, e.g. scar:dog:medium (repeatable)")
    args = ap.parse_args()

    env = load_env(args.env)
    base = env["REACT_APP_SUPABASE_URL"].rstrip("/")
    key = env["REACT_APP_SUPABASE_ANON_KEY"]
    hdr = {"apikey": key, "Authorization": f"Bearer {key}"}
    pets = json.loads(get(f"{base}/rest/v1/pets?select=name,type,size", hdr))
    by_name = {p["name"].lower(): p for p in pets}
    for spec in args.pet:
        name, ptype, size = spec.split(":")
        by_name[name.lower()] = {"name": name.title(), "type": ptype, "size": size}

    os.makedirs(args.dst, exist_ok=True)
    problems = 0
    for fname in sorted(os.listdir(args.src)):
        if not fname.lower().endswith(".glb"):
            continue
        stem = fname[:-4].lower()
        pet = by_name.get(stem)
        if not pet:
            print(f"SKIP {fname}: no pet named '{stem}' ({', '.join(sorted(by_name))})")
            problems += 1
            continue
        path = os.path.join(args.src, fname)
        if args.shrink and os.path.getsize(path) / 1e6 > WARN_MB:
            small = os.path.join(tempfile.mkdtemp(), fname)
            shrink(path, small)
            path = small
        gltf, binary = read_glb(path)
        if "KHR_draco_mesh_compression" in gltf.get("extensionsUsed", []):
            print(f"FAIL {fname}: Draco-compressed; export again without compression")
            problems += 1
            continue
        height = expected_height(pet["type"], pet["size"])
        before, factor = normalize(gltf, binary, height)
        assert abs(model_height(gltf) - height) < 1e-4
        gltf["asset"]["extras"]["poseRatio"] = 1.0
        ground(gltf)
        matte(gltf)
        out = os.path.join(args.dst, stem + ".glb")
        write_glb(out, gltf, binary)
        mb = os.path.getsize(out) / 1e6
        flag = "FAIL too big" if mb > MAX_MB else "large" if mb > WARN_MB else "ok"
        problems += mb > MAX_MB
        print(f"{pet['name']:<8} {pet['type']}/{pet['size']:<7} {before:7.3f} -> {height:.2f} m  "
              f"{mb:5.1f} MB  {flag}")
    sys.exit(1 if problems else 0)


if __name__ == "__main__":
    main()
