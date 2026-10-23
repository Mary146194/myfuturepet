"""Check that every pet's 3D model is life size for its type and size.

    python scripts/check_glb_scale.py --env ../myfuturepet/admin/.env

Reads pets (public read, anon key) from Supabase, downloads each distinct model and
compares its idle-pose standing height with the expected value in glb_tools.EXPECTED_HEIGHT_M.
Exit code 1 if any pet is outside +/-10 %.
"""
import argparse
import json
import os
import sys
import tempfile
import urllib.request

from glb_tools import TOLERANCE, expected_height, idle_height, read_glb


def load_env(path):
    out = {}
    for line in open(path, encoding="utf-8"):
        if "=" in line and not line.lstrip().startswith("#"):
            k, v = line.strip().split("=", 1)
            out[k] = v
    return out


def get(url, headers=None):
    req = urllib.request.Request(url, headers=headers or {})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--env", help=".env with REACT_APP_SUPABASE_URL / _ANON_KEY")
    args = ap.parse_args()
    env = load_env(args.env) if args.env else os.environ
    base = env["REACT_APP_SUPABASE_URL"].rstrip("/")
    key = env["REACT_APP_SUPABASE_ANON_KEY"]
    hdr = {"apikey": key, "Authorization": f"Bearer {key}"}
    pets = json.loads(get(f"{base}/rest/v1/pets?select=name,type,size,model_url&order=name", hdr))

    cache, bad = {}, 0
    tmp = tempfile.mkdtemp()
    for pet in pets:
        url = pet.get("model_url")
        if not url:
            print(f"SKIP {pet['name']}: no model_url")
            continue
        if url not in cache:
            path = os.path.join(tmp, f"m{len(cache)}.glb")
            open(path, "wb").write(get(url))
            cache[url] = read_glb(path)[0]
        got = idle_height(cache[url], pet["type"])
        want = expected_height(pet["type"], pet["size"])
        ok = abs(got - want) <= want * TOLERANCE
        bad += 0 if ok else 1
        print(f"{'PASS' if ok else 'FAIL'} {pet['name']:<8} {pet['type']}/{pet['size']:<7} "
              f"model {got:7.3f} m  expected {want:.2f} m")
    print("all models life size" if not bad else f"{bad} pet(s) have a wrong-size model")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
