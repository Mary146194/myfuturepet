"""Tiny GLB helpers shared by normalize_glb.py and check_glb_scale.py (stdlib only)."""
import json
import struct

# glTF units are metres. Expected overall model height (top of head, standing
# pose) per pet, in metres. Shoulder heights the app shows are 25 / 28 / 45 / 60 cm;
# the model's bounding box also includes the head, hence the larger numbers.
EXPECTED_HEIGHT_M = {
    ("cat", "small"): 0.30,
    ("cat", "medium"): 0.30,
    ("cat", "large"): 0.30,
    ("dog", "small"): 0.35,
    ("dog", "medium"): 0.56,
    ("dog", "large"): 0.75,
}
TOLERANCE = 0.10  # +/-10 %

# The animated "idle" pose is taller than the bind-pose bounding box stored in the
# file (head up, legs extended). Measured by rendering the models in <model-viewer>
# (2026-10-23): dog 1.12x, cat 1.04x. EXPECTED_HEIGHT_M is the idle-pose height.
IDLE_POSE_RATIO = {"dog": 1.12, "cat": 1.04}


def read_glb(path):
    data = open(path, "rb").read()
    magic, version, _ = struct.unpack("<4sII", data[:12])
    if magic != b"glTF" or version != 2:
        raise ValueError(f"{path}: not a glTF 2.0 binary")
    jlen, jtype = struct.unpack("<I4s", data[12:20])
    gltf = json.loads(data[20:20 + jlen])
    off = 20 + jlen
    off += (-off) % 4
    blen, btype = struct.unpack("<I4s", data[off:off + 8])
    if btype != b"BIN\x00":
        raise ValueError(f"{path}: missing BIN chunk")
    return gltf, bytearray(data[off + 8:off + 8 + blen])


def write_glb(path, gltf, binary):
    jbytes = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
    jbytes += b" " * ((-len(jbytes)) % 4)
    binary = bytes(binary) + b"\x00" * ((-len(binary)) % 4)
    total = 12 + 8 + len(jbytes) + 8 + len(binary)
    with open(path, "wb") as f:
        f.write(struct.pack("<4sII", b"glTF", 2, total))
        f.write(struct.pack("<I4s", len(jbytes), b"JSON") + jbytes)
        f.write(struct.pack("<I4s", len(binary), b"BIN\x00") + binary)


def position_bounds(gltf):
    """Union min/max of every mesh POSITION accessor (rest pose)."""
    mins, maxs = [], []
    for mesh in gltf["meshes"]:
        for prim in mesh["primitives"]:
            acc = gltf["accessors"][prim["attributes"]["POSITION"]]
            mins.append(acc["min"])
            maxs.append(acc["max"])
    lo = [min(m[i] for m in mins) for i in range(3)]
    hi = [max(m[i] for m in maxs) for i in range(3)]
    return lo, hi


def model_height(gltf):
    lo, hi = position_bounds(gltf)
    return hi[1] - lo[1]


def idle_height(gltf, pet_type):
    """Approximate standing height as seen in the idle animation."""
    return model_height(gltf) * IDLE_POSE_RATIO.get(str(pet_type).lower(), 1.0)


def expected_height(pet_type, size):
    key = (str(pet_type or "dog").lower(), str(size or "medium").lower())
    return EXPECTED_HEIGHT_M.get(key) or EXPECTED_HEIGHT_M[(key[0], "medium")]
