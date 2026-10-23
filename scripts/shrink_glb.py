"""Shrink a heavy GLB (e.g. a Meshy export) for phones: fewer triangles, smaller textures.

    python scripts/shrink_glb.py in.glb out.glb [--faces 30000] [--texture 1024]

Runs @gltf-transform/cli through npx (needs Node): weld -> simplify -> resize textures
-> convert PNG textures to JPEG -> prune. Output stays plain glTF (no Draco, meshopt
or KTX2), which Android Scene Viewer and <model-viewer> both read.
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile

from glb_tools import read_glb

CLI = ["npx", "--yes", "@gltf-transform/cli@4"]


def face_count(gltf):
    total = 0
    for mesh in gltf["meshes"]:
        for prim in mesh["primitives"]:
            if "indices" in prim:
                total += gltf["accessors"][prim["indices"]]["count"] // 3
            else:
                total += gltf["accessors"][prim["attributes"]["POSITION"]]["count"] // 3
    return total


def run(*args):
    cmd = CLI + [str(a) for a in args]
    # npx is npx.cmd on Windows
    proc = subprocess.run(cmd, capture_output=True, text=True, shell=(os.name == "nt"))
    if proc.returncode != 0:
        sys.exit(f"gltf-transform failed: {' '.join(args)}\n{proc.stderr[-1500:]}")


def shrink(src, dst, faces=30000, texture=1024, quality=88):
    gltf, _ = read_glb(src)
    before = face_count(gltf)
    ratio = min(1.0, faces / before) if before else 1.0
    tmp = tempfile.mkdtemp()
    a, b = os.path.join(tmp, "a.glb"), os.path.join(tmp, "b.glb")
    run("weld", src, a)
    run("simplify", a, b, "--ratio", f"{ratio:.4f}", "--error", "0.001")
    run("resize", b, a, "--width", texture, "--height", texture)
    run("jpeg", a, b, "--formats", "*", "--quality", quality)
    run("prune", b, a)
    shutil.copyfile(a, dst)
    after = face_count(read_glb(dst)[0])
    print(f"{os.path.basename(src)}: {before:,} -> {after:,} faces, "
          f"{os.path.getsize(src) / 1e6:.1f} -> {os.path.getsize(dst) / 1e6:.1f} MB")
    shutil.rmtree(tmp, ignore_errors=True)
    return after


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--faces", type=int, default=30000, help="target triangle count")
    ap.add_argument("--texture", type=int, default=1024, help="max texture size in px")
    args = ap.parse_args()
    shrink(args.src, args.dst, args.faces, args.texture)


if __name__ == "__main__":
    main()
