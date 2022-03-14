import bpy, bmesh, math, random, os, datetime

def console(data, level = "OUTPUT"):
    for window in bpy.context.window_manager.windows:
        screen = window.screen
        for area in screen.areas:
            if area.type == 'CONSOLE':
                override = {'window': window, 'screen': screen, 'area': area}
                bpy.ops.console.scrollback_append(override, text = str(data), type = level)

def print(data):
    console(data)
                
def error(data):
    console(data, "ERROR")

def radians(degrees):
    return (degrees * math.pi) / 180

def sin(degrees):
    return math.sin(radians(degrees))

def cos(degrees):
    return math.cos(radians(degrees))

def tan(degrees):
    return math.tan(radians(degrees))

def Grid(blocks = 8):
    verts = []
    edges = []
    faces = []
    uvmap = []
    x = [ 0.5,  0.5, -0.5, -0.5,  0.5, -0.5, -0.5,  0.5 ]
    y = [ 0.5, -0.5, -0.5,  0.5,  0.5,  0.5, -0.5, -0.5 ]
    z = [ 0.5,  0.5,  0.5,  0.5, -0.5, -0.5, -0.5, -0.5 ]
    t = \
    [
        (0, 1), (1, 2), (2, 3), (3, 0),
        (4, 5), (5, 6), (6, 7), (7, 4),
        (0, 4), (1, 7), (2, 6), (3, 5),
    ]
    ie = \
    [
        (0, 1, 2, 3),
        (0, 4, 7, 1),
        (1, 7, 6, 2),
        (2, 6, 5, 3),
        (3, 5, 4, 0),
        (4 ,5, 6, 7),
    ]
    uv = \
    [
        (0, 0),
        (1, 0),
        (1, 1),
        (0, 1),
    ]
    o = (-blocks / 2) + 0.5
    s = 1.0 / (blocks * blocks * blocks)
    
    it1 = []
    for i in range(0, len(ie)):
        it2 = list(ie[i][:])
        ien = len(ie[i])
        for j in range(0, ien):
            it2[j] = ie[i][ien - j - 1]
        it1.append(it2)
    ie = it1 # Flipping Normals
    
    for cx in range(0, blocks):
        for cy in range(0, blocks):
            for cz in range(0, blocks):
                i = (cx * blocks * blocks) + (cy * blocks) + cz
                for v in range(0, 8):
                    verts.append(
                    (
                        o + cx + x[v],
                        o + cy + y[v],
                        o + cz + z[v])
                    )
                for e in range(0, len(t)):
                    ci = i * 8
                    edges.append(
                    (
                        ci + t[e][0],
                        ci + t[e][1])
                    )
                for f in range(0, len(ie)):
                    ch = i * 8
                    faces.append(
                    (
                        ch + ie[f][0],
                        ch + ie[f][1],
                        ch + ie[f][2],
                        ch + ie[f][3])
                    )
                    uvc = s * i
                    uvs = uv[:]
                    uvmap.append(
                    (
                        (uvc + (uv[0][0] * s), uvc * uv[0][1]),
                        (uvc + (uv[1][0] * s), uvc * uv[1][1]),
                        (uvc + (uv[2][0] * s), uvc * uv[2][1]),
                        (uvc + (uv[3][0] * s), uvc * uv[3][1]))
                    )
    return (verts, edges, faces, uvmap)

def hex2rgba(cmd):
    result = [0.0] * 7
    result[0] = float(int(cmd[0], 16))
    result[1] = float(int(cmd[1], 16))
    result[2] = float(int(cmd[2], 16))
    result[3] = float(int(cmd[3], 16)) / 255.0
    result[4] = float(int(cmd[4], 16)) / 255.0
    result[5] = float(int(cmd[5], 16)) / 255.0
    result[6] = float(int(cmd[6], 16)) / 255.0
    return result

def make(name, data):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(*(data[0:3]))
    mesh.update()
    
    obj = bpy.data.objects.new(name, mesh)
    uvs = obj.data.uv_layers.new(name = "UV0")
    mdi = 0
    for loop in obj.data.loops:
        uvi = int(loop.index / 4)
        #print(data[3][uvi][mdi])
        #uvs.data[loop.index].uv = (0, 0)
        uvs.data[loop.index].uv = data[3][uvi][mdi]
        mdi += 1
        if mdi >= 4:
            mdi = 0
    
    scene = bpy.context.scene.collection.children[0]
    scene.objects.link(obj)
    obj.select_set(True)
    return obj

def paint(obj, data, blocks = 8):
    mat = bpy.data.materials.new("PixelFire")
    mat.use_nodes = True
    mat.blend_method = "BLEND"
    
    nod = mat.node_tree.nodes
    lnk = mat.node_tree.links
    shd = nod.get("Principled BSDF")
    col = shd.inputs["Base Color"]
    col.default_value = (1.0, 0.0, 0.0, 1.0)
    tex = nod.new("ShaderNodeTexImage")
    txi = tex.outputs["Color"]
    lnk.new(col, txi)
    al1 = shd.inputs["Alpha"]
    al2 = tex.outputs["Alpha"]
    lnk.new(al1, al2)
    
    siz = blocks * blocks * blocks
    uid = "PixelFire" + "_0x{:08X}".format(int(random.random() * 0xFFFFFFFF))
    bpy.ops.image.new(name = uid, width = siz, height = 1, color = (0.0, 0.0, 0.0, 0.0), alpha = True)
    img = bpy.data.images[uid]
    tex.image = img
    
    fil = open(os.path.join(bpy.path.abspath("//"), data), "r")
    dat = fil.readlines()
    fil.close()
    
    F = 0
    for lin in dat:
        lni = lin.split("//")[0].split("#")[0].replace("\r", "").replace("\n", "").replace(" ", "")
        if lni and len(lni) > 0 and lni[0] == "[":
            F += 1
            if F > 1: #Temporary, KeyFraming Not Working Yet
                break
        cmd = lni.split(",")
        if cmd and len(cmd) == 7:
            cmd = hex2rgba(cmd)
            xxx, yyy, zzz, rrr, ggg, bbb, aaa = cmd
            iii = 4 * int((xxx * blocks * blocks) + (yyy * blocks) + zzz)
            img.pixels[iii    ] = rrr
            img.pixels[iii + 1] = ggg
            img.pixels[iii + 2] = bbb
            img.pixels[iii + 3] = aaa
    print(F)
    
    obj.data.materials.append(mat)
    return obj

try:
    error("Decoding Encrypted Engram...")
    random.seed(datetime.datetime.now())
    bpy.context.view_layer.active_layer_collection = bpy.context.view_layer.layer_collection.children[0]
    
    grid = make("Grid", Grid()) # TODO: Add Material, Read File and Insert Keyframes for FBX Export
    grid = paint(grid, "PixelFire.txt")
    
    print("Master Rahool is finished.")
except Exception as e:
    error(e)