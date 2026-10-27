import bpy, math
from mathutils import Vector
def setup_render(res=512):
    sc=bpy.context.scene
    sc.render.engine='BLENDER_WORKBENCH'
    sc.display.shading.light='STUDIO'
    sc.display.shading.color_type='TEXTURE'
    sc.render.resolution_x=sc.render.resolution_y=res
    sc.render.film_transparent=False
    w=bpy.data.worlds.new("w"); sc.world=w
def shoot(path, loc, target=(0,0,0.28), ortho=0.9):
    sc=bpy.context.scene
    cam=sc.camera
    if cam is None:
        cd=bpy.data.cameras.new("c"); cam=bpy.data.objects.new("c",cd); sc.collection.objects.link(cam); sc.camera=cam
    cam.data.type='ORTHO'; cam.data.ortho_scale=ortho
    cam.location=Vector(loc)
    d=Vector(target)-cam.location
    cam.rotation_euler=d.to_track_quat('-Z','Y').to_euler()
    sc.render.filepath=path
    bpy.ops.render.render(write_still=True)
