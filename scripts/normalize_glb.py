"""Rescale a skinned, animated GLB so its standing height is a real size in metres.

glTF units are metres, and Android Scene Viewer shows a model at the size stored in
the file. The pet models were authored at arbitrary scale (dog ~40 units, cat ~13), so
they appear at the wrong size in AR. This bakes a uniform scale into the data (vertex
positions, joint translations, inverse bind matrices, translation animation tracks)
instead of adding a parent-node scale, which skinned meshes ignore in some viewers.

    python scripts/normalize_glb.py dog.glb dog_medium.glb --type dog --height-m 0.56

--height-m is the height of the *idle animation pose*; the stored bind-pose box is
smaller by IDLE_POSE_RATIO (see glb_tools.py). For a static model with no animation
(e.g. a Meshy export) pass --pose-ratio 1, and --ground to put the feet on the floor
at the origin, which Scene Viewer needs:

    python scripts/normalize_glb.py meshy_bella.glb bella.glb --type dog --height-m 0.56 --pose-ratio 1 --ground
"""
import argparse
import struct

from glb_tools import IDLE_POSE_RATIO, model_height, position_bounds, read_glb, write_glb


def _accessor_span(gltf, idx, comps):
    acc = gltf["accessors"][idx]
    if acc["componentType"] != 5126:
        raise ValueError(f"accessor {idx} is not float32")
    view = gltf["bufferViews"][acc["bufferView"]]
    start = view.get("byteOffset", 0) + acc.get("byteOffset", 0)
    stride = view.get("byteStride") or comps * 4
    return acc, start, stride


def _scale_floats(gltf, binary, idx, comps, positions, factor):
    """Multiply the given component positions of every element of an accessor."""
    acc, start, stride = _accessor_span(gltf, idx, comps)
    for i in range(acc["count"]):
        base = start + i * stride
        vals = list(struct.unpack_from(f"<{comps}f", binary, base))
        for p in positions:
            vals[p] *= factor
        struct.pack_into(f"<{comps}f", binary, base, *vals)
    if list(positions) == list(range(comps)) and "min" in acc and "max" in acc:
        acc["min"] = [v * factor for v in acc["min"]]
        acc["max"] = [v * factor for v in acc["max"]]


def normalize(gltf, binary, target_height_m):
    current = model_height(gltf)
    factor = target_height_m / current
    done = set()

    def once(idx):
        if idx in done:
            return False
        done.add(idx)
        return True

    for mesh in gltf["meshes"]:
        for prim in mesh["primitives"]:
            idx = prim["attributes"]["POSITION"]
            if once(("pos", idx)):
                _scale_floats(gltf, binary, idx, 3, range(3), factor)
    for skin in gltf.get("skins", []):
        idx = skin.get("inverseBindMatrices")
        if idx is not None and once(("ibm", idx)):
            _scale_floats(gltf, binary, idx, 16, (12, 13, 14), factor)
    for anim in gltf.get("animations", []):
        for ch in anim["channels"]:
            if ch["target"]["path"] != "translation":
                continue
            idx = anim["samplers"][ch["sampler"]]["output"]
            if once(("anim", idx)):
                _scale_floats(gltf, binary, idx, 3, range(3), factor)
    for node in gltf["nodes"]:
        if "translation" in node:
            node["translation"] = [v * factor for v in node["translation"]]
    asset = gltf.setdefault("asset", {})
    asset.setdefault("extras", {})["normalizedHeightM"] = round(target_height_m, 4)
    return current, factor


def ground(gltf):
    """Shift every scene root node so the feet sit at y=0 and the model is centred on x/z."""
    lo, hi = position_bounds(gltf)
    offset = [-(lo[0] + hi[0]) / 2, -lo[1], -(lo[2] + hi[2]) / 2]
    scene = gltf["scenes"][gltf.get("scene", 0)]
    for idx in scene["nodes"]:
        node = gltf["nodes"][idx]
        if "matrix" in node:
            raise ValueError(f"root node {idx} uses a matrix; cannot ground automatically")
        t = node.get("translation", [0, 0, 0])
        node["translation"] = [t[i] + offset[i] for i in range(3)]
    return offset


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--type", choices=sorted(IDLE_POSE_RATIO), required=True)
    ap.add_argument("--height-m", type=float, required=True,
                    help="target standing height (top of head, idle pose) in metres")
    ap.add_argument("--pose-ratio", type=float,
                    help="idle-pose height / stored box height; 1 for static models")
    ap.add_argument("--ground", action="store_true",
                    help="move the feet to y=0 and centre on x/z (Meshy-style models)")
    args = ap.parse_args()
    gltf, binary = read_glb(args.src)
    ratio = args.pose_ratio if args.pose_ratio is not None else IDLE_POSE_RATIO[args.type]
    bind_target = args.height_m / ratio
    before, factor = normalize(gltf, binary, bind_target)
    after = model_height(gltf)
    assert abs(after - bind_target) < 1e-4, (after, bind_target)
    gltf["asset"]["extras"]["poseRatio"] = ratio
    if args.ground:
        ground(gltf)
    write_glb(args.dst, gltf, binary)
    print(f"{args.src}: bind {before:.3f} -> {after:.3f} m (x{factor:.5f}), "
          f"standing ~{args.height_m:.2f} m, saved {args.dst}")


if __name__ == "__main__":
    main()
