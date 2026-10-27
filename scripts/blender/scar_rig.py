"""Rig Scar (static Meshy model) with a "Wag" loop and a "Sit" clip. Blender 5.2:

    blender -b --python scripts/blender/scar_rig.py -- --render   (check frames + floor clearance)
    blender -b --python scripts/blender/scar_rig.py -- --export   (scar_anim.glb)

Pose overrides for tuning: spine=-43 thigh=-26 ... and mid.shin=70 for the halfway key.
After export set asset.extras.poseRatio = 1.0 so check_glb_scale.py reads the height right.
"""
import bpy, math, sys, os
from mathutils import Vector, Matrix
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from render_helpers import setup_render, shoot
SRC = r"C:\Users\Acer User\Videos\MyFuturePetV1\ar_models_normalized\scar.glb"
OUT = os.path.dirname(SRC)
args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []

bpy.ops.wm.read_factory_settings(use_empty=True)
bpy.ops.import_scene.gltf(filepath=SRC)
mesh = [o for o in bpy.context.scene.objects if o.type == 'MESH'][0]
P = lambda y, z: Vector((0, y, z))   # every bone lies in the mid plane x=0

# Joints measured from mesh slices (Blender: +Y = back, Z up), metres.
TAIL = [P(.250, .395), P(.278, .340), P(.296, .280), P(.322, .235), P(.355, .200), P(.394, .166)]
SHOULDER, HIP = P(-.12, .37), P(.22, .35)
KNEE, HOCK, PAW = P(.20, .245), P(.29, .10), P(.285, .015)
# name: (head, tail, parent, connected)
BONES = {
    "root": (P(-.15, .40), P(-.32, .47), None, False),      # neck + head stay put
    "spine": (SHOULDER, HIP, "root", False),
    "thigh": (HIP, KNEE, "spine", False),
    "shin": (KNEE, HOCK, "thigh", True),
    "foot": (HOCK, PAW, "shin", True),
}
for i in range(len(TAIL) - 1):
    BONES[f"tail_{i}"] = (TAIL[i], TAIL[i + 1], "spine" if i == 0 else f"tail_{i-1}", i > 0)
TAILS = [n for n in BONES if n.startswith("tail_")]

# Body weighting: soft nearest "capsule" in the side plane. Front legs count as root.
CAPSULES = [  # (bone, a, b, radius)
    ("root", P(-.15, .40), P(-.40, .47), .07),
    ("root", P(-.125, .26), P(-.13, .0), .03),                 # front legs
    ("spine", SHOULDER + P(.03, 0), HIP + P(.02, .0), .085),
    ("thigh", HIP, KNEE, .04),
    ("shin", KNEE, HOCK, .025),
    ("foot", HOCK, PAW + P(-.01, 0), .025),
]
SIGMA = .012

arm_data = bpy.data.armatures.new("ScarRig")
arm = bpy.data.objects.new("ScarRig", arm_data)
bpy.context.scene.collection.objects.link(arm)
bpy.context.view_layer.objects.active = arm
bpy.ops.object.mode_set(mode='EDIT')
for name, (h, t, parent, conn) in BONES.items():
    b = arm_data.edit_bones.new(name)
    b.head, b.tail = h, t
    b.align_roll(Vector((1, 0, 0)).cross((t - h).normalized()))
    if parent:
        b.parent = arm_data.edit_bones[parent]
        b.use_connect = conn
bpy.ops.object.mode_set(mode='OBJECT')
assert all(abs(b.x_axis.x - 1) < 1e-4 for b in arm_data.bones), "bones must turn about world X"

def seg(p, a, b):
    ab = b - a
    t = max(0.0, min(1.0, (p - a).dot(ab) / ab.length_squared))
    return t, (p - (a + ab * t))

def smooth(e0, e1, x):
    t = max(0.0, min(1.0, (x - e0) / (e1 - e0)))
    return t * t * (3 - 2 * t)

def tail_weight(p):
    best = (1e9, 0.0)
    for i in range(len(TAIL) - 1):
        t, off = seg(p, TAIL[i], TAIL[i + 1])
        if off.length < best[0]:
            best = (off.length, i + t)
    dist, s = best
    return (1 - smooth(.034 * .6, .034, dist)) * smooth(0.0, 1.5, s), s

groups = {n: mesh.vertex_groups.new(name=n) for n in BONES}
for v in mesh.data.vertices:
    p = mesh.matrix_world @ v.co
    q = Vector((0, p.y, p.z))                     # legs mirror: ignore x
    raw = {}
    for name, a, b, r in CAPSULES:
        d = max(0.0, seg(q, a, b)[1].length - r)
        raw[name] = max(raw.get(name, 0.0), math.exp(-d / SIGMA))
    tot = sum(raw.values())
    w_tail, s = tail_weight(p)
    for name, w in raw.items():
        w = w / tot * (1 - w_tail)
        if w > 1e-3:
            groups[name].add([v.index], w, 'REPLACE')
    if w_tail > 1e-3:
        i = min(int(s), len(TAILS) - 1)
        f = s - i if i + 1 < len(TAILS) else 0.0
        groups[TAILS[i]].add([v.index], w_tail * (1 - f), 'ADD')
        if f:
            groups[TAILS[i + 1]].add([v.index], w_tail * f, 'ADD')

mesh.parent = arm
mesh.modifiers.new("Armature", 'ARMATURE').object = arm
for pb in arm.pose.bones:
    pb.rotation_mode = 'XYZ'

sc = bpy.context.scene
sc.render.fps = 24

def new_action(name):
    act = bpy.data.actions.new(name)
    arm.animation_data_create()
    arm.animation_data.action = act
    return act

def key(frame, angles):
    for name in BONES:
        if name == "root":
            continue
        arm.pose.bones[name].rotation_euler = (math.radians(angles.get(name, 0)), 0, 0)
        arm.pose.bones[name].keyframe_insert("rotation_euler", frame=frame)

def key_z(frame, angles):
    for i, name in enumerate(TAILS):
        arm.pose.bones[name].rotation_euler = (0, 0, math.radians(angles[i]))
        arm.pose.bones[name].keyframe_insert("rotation_euler", frame=frame)

# Wag: 1 s loop, 2 wags, each tail bone lags the one above it.
SWING = [3, 7, 18, 16, 12]
wag = new_action("Wag")
for f in range(25):
    key_z(f, [SWING[i] * math.sin(2 * math.pi * 2 * f / 24 - 0.7 * i) for i in range(len(TAILS))])

# Sit: rump down about the shoulders, hind legs fold, tail laid back. Local X turns.
SIT = {"spine": -43, "thigh": -26, "shin": 103, "foot": -121,
       "tail_0": 45, "tail_1": 30, "tail_2": 20}
# Halfway: rump half down, legs folded just enough to keep the paws on the floor.
MID = {"spine": -22, "thigh": -18, "shin": 70, "foot": -80,
       "tail_0": 20, "tail_1": 15, "tail_2": 10}
for k, v in [kv.split("=") for kv in args if "=" in kv]:
    (MID if k.startswith("mid.") else SIT)[k.removeprefix("mid.")] = float(v)
sit = new_action("Sit")
key(0, {})
key(9, MID)
key(18, SIT)

# Keep both clips: one NLA track each, no active action.
for act in (wag, sit):
    tr = arm.animation_data.nla_tracks.new()
    tr.name = act.name
    tr.strips.new(act.name, 0, act)
arm.animation_data.action = None

def posed_min_z():
    dg = bpy.context.evaluated_depsgraph_get()
    ev = mesh.evaluated_get(dg)
    m = ev.to_mesh()
    tail = {g.index for g in mesh.vertex_groups if g.name.startswith("tail_")}
    zs = [((mesh.matrix_world @ v.co).z, any(g.group in tail and g.weight > .5 for g in mesh.data.vertices[v.index].groups)) for v in m.vertices]
    ev.to_mesh_clear()
    return min(z for z, t in zs if not t), min(z for z, t in zs if t)

if "--render" in args or "--measure" in args:
    setup_render(400)
    arm.animation_data.action = sit
    sc.frame_set(18)
    print("SIT min z body/tail", [round(z, 3) for z in posed_min_z()])
    if "--quick" in args:
        sc.frame_set(9); print("MID min z body/tail", [round(z, 3) for z in posed_min_z()]); sys.exit(0)
    shoot(f"{OUT}/sit_side.png", (2, 0, 0.25), target=(0, 0, 0.25), ortho=0.9)
    shoot(f"{OUT}/sit_q.png", (1.6, -1.4, 0.7), target=(0, 0.05, 0.22), ortho=0.9)
    shoot(f"{OUT}/sit_back.png", (0.0, 2.0, 0.3), target=(0, 0, 0.25), ortho=0.8)
    sc.frame_set(9)
    print("MID min z body/tail", [round(z, 3) for z in posed_min_z()])
    if "--quick" in args:
        sys.exit(0)
    shoot(f"{OUT}/sit_mid.png", (2, 0, 0.25), target=(0, 0, 0.25), ortho=0.9)
    arm.animation_data.action = None
if "--export" in args:
    sc.frame_set(0)
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=OUT + "/scar_anim.glb", export_format='GLB',
                              export_animations=True, export_skins=True, use_selection=True,
                              export_animation_mode='NLA_TRACKS')
