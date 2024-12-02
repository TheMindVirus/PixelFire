import bpy, bmesh, math

def console(*data, level = "OUTPUT"):
    raw = ""
    for item in data:
        raw += str(item)
    for window in bpy.context.window_manager.windows:
        screen = window.screen
        for area in screen.areas:
            if area.type == "CONSOLE":
                override = { "window": window, "screen": screen, "area": area }
                bpy.ops.console.scrollback_append(override, text = raw, type = level)

def print(*data):
    console(*data)
                
def error(*data):
    console(*data, level = "ERROR")
    
def redprint(*data):
    console(*data, level = "ERROR")

def radians(degrees):
    return (degrees * math.pi) / 180

def degrees(phase):
    return (phase * 360)

def phase(degrees_list):
    phase_list = []
    for i in range(0, len(degrees_list)):
        phase_list.append(degrees_list[i] / 360)
    return phase_list

def sin(phase):
    return math.sin(radians(degrees(phase)))

def cos(phase):
    return math.cos(radians(degrees(phase)))

def tan(phase):
    return math.tan(radians(degrees(phase)))

def arc_solver \
(
    x1 = 0, y1 = 0, z1 = -1,
    x2 = 0, y2 = 0, z2 = 1,
    x0 = 0, y0 = 0, z0 = 0
):
    x1 = x1 - x0
    y1 = y1 - y0
    z1 = z1 - z0
    x2 = x2 - x0
    y2 = y2 - y0
    z2 = z2 - z0
    rx = 0
    ry = 0 ##!!!
    rz = 0
    return (rx, ry, rz)

def Rotate \
(
    cx = 0, cy = 0, cz = 0,
    rx = 0, ry = 0, rz = 0,
    px = 0, py = 0, pz = 0
):
    mx = cx - px
    my = cy - py
    mz = cz - pz
    
    mx1 = cos(rx) * cos(rz)
    mx2 = (-cos(ry) * sin(rz)) + (sin(ry) * sin(rx) * cos(rz))
    mx3 = (sin(ry) * sin(rz)) + (cos(ry) * sin(rx) * cos(rz))

    my1 = cos(rx) * sin(rz)
    my2 = (cos(ry) * cos(rz)) + (sin(ry) * sin(rx) * sin(rz))
    my3 = (-sin(ry) * cos(rz)) + (cos(ry) * sin(rx) * sin(rz))

    mz1 = -sin(rx)
    mz2 = sin(ry) * cos(rx)
    mz3 = cos(ry) * cos(rx)

    nx = (mx1 * mx) + (mx2 * my) + (mx3 * mz)
    ny = (my1 * mx) + (my2 * my) + (my3 * mz)
    nz = (mz1 * mx) + (mz2 * my) + (mz3 * mz)
    
    nx = nx + px
    ny = ny + py
    nz = nz + pz
    
    return (nx, ny, nz)

def Arc \
(
    x1 = 0, y1 = 0, z1 = -1,
    x2 = 0, y2 = 0, z2 = 1,
    xc = 0, yc = 0, zc = 0,
    xr = 0, yr = 0.5, zr = 0,
    segments = 24
):
    verts = []
    edges = []
    cx = x1
    cy = y1
    cz = z1
    rx = xr / segments
    ry = yr / segments
    rz = zr / segments
    c = 0
    redprint(x1, y1, z1)
    verts.append([x1, y1, z1])
    for i in range(0, segments - 1):
        nx, ny, nz = Rotate(cx, cy, cz, rx, ry, rz, xc, yc, zc)
        print(nx, ny, nz)
        verts.append([nx, ny, nz])
        edges.append([c, c + 1])
        cx = nx
        cy = ny
        cz = nz
        c += 1
    redprint(x2, y2, z2)
    verts.append([x2, y2, z2])
    edges.append([c, c + 1])
    c += 1
    return (verts, edges, []) #(verts, edges)

def Orb(r = 1, s1 = 24, s2 = 24):
    verts = []
    edges = []
    faces = []
    e = s1 + 1
    nan = float("NaN")
    for i in range(0, e):
        _verts, _edges, _faces = Arc()
        for j in range(0, len(_verts)):
            x, y, z = _verts[j]
            n = i / e
            nx, ny, nz = [nan, nan, nan]
            if 1: #if i == 0 or (j > 0 and j < e):
                nx, ny, nz = Rotate(x, y, z, 0, 0, -n, 0, 0, s2)
            verts.append([nx, ny, nz])
        for j in range(0, len(_edges)):
            a, b = _edges[j]
            n = i * e
            e = s1 + 1
            a = a + n
            b = b + n
            ae = a % e
            be = b % e
            a = 0 if ae == 0 else s1 if ae == s1 else a
            b = 0 if be == 0 else s1 if be == s1 else b
            edges.append([a, b])
    s3 = len(verts)
    for i in range(0, s3 - s1):
        n = int(i / s1)
        a = n+i
        b = n+i+1
        c = n+i+s1+2
        d = n+i+s1+1
        ae = a % e
        be = b % e
        ce = c % e
        de = d % e
        a = 0 if ae == 0 else s1 if ae == s1 else a
        b = 0 if be == 0 else s1 if be == s1 else b
        c = 0 if ce == 0 else s1 if ce == s1 else c
        d = 0 if de == 0 else s1 if de == s1 else d
        faces.append([a % s3, b % s3, c % s3, d % s3])
    return (verts, edges, faces)

def Tectum(label = "Tectum", spot_list =
[
    -1.866773354482507,
    53.7534160222309,
    0,
    138.8450741587487,
    35.72620767874357,
    0,
    173.195785012192,
    -42.09422874220527,
    0,
    46.60112022677559,
    -19.24819786660256,
    0,
    -1.523356925810183,
    53.71973399832747,
    0 
], segments = 10, thickness = 0.1, solver = "EXACT"):
    verts = []
    edges = []
    faces = []
    region = make(label, Orb())
    bpy.ops.object.shade_smooth()
    for i in range(0, len(spot_list) - 3, 3):
        x0, y0, z0 = [0, 0, 0]
        x1, y1, z1 = Rotate(0, 0, 1, *phase(spot_list[i+0:i+3]))
        x2, y2, z2 = Rotate(0, 0, 1, *phase(spot_list[i+3:i+6]))
        xr, yr, zr = arc_solver(x1, y1, z1,
                                x2, y2, z2,
                                x0, y0, z0)
        _verts, _edges, _ = Arc(x1, y1, z1,
                                x2, y2, z2,
                                x0, y0, z0,
                                xr, yr, zr,
                                segments = segments)
        verts += _verts[(i > 0):]
    sz = len(verts)
    for i in range(0, sz):
        edges.append([i, (i + 1) % sz])
    tmp_name = "___tmp___"
    obj = make(tmp_name, (verts, edges, faces))
    bpy.ops.object.editmode_toggle()
    bpy.ops.mesh.extrude_region()
    bpy.ops.transform.resize(value = (2, 2, 2),
                             center_override = (0, 0, 0))
    #bpy.ops.selection.invert()
    bpy.ops.mesh.select_all(action = "INVERT")
    bpy.ops.transform.resize(value = (0, 0, 0),
                             center_override = (0, 0, 0))
    #bpy.ops.object.select_all()
    bpy.ops.mesh.select_all(action = "SELECT")
    bpy.ops.mesh.extrude_region()
    bpy.ops.transform.translate(value = (0, 0, thickness),
                                constraint_axis = (False, False, True),
                                orient_type = "NORMAL")
                                #constraint_orientation = "LOCAL")
    bpy.ops.object.editmode_toggle()
    bpy.ops.object.select_all(action = "DESELECT")
    region.select_set(True)
    bpy.context.view_layer.objects.active = region
    #bpy.ops.modifiers.boolean()
    #bpy.ops.object.editmode_toggle()
    #bpy.ops.mesh.intersect_boolean(operation = "DIFFERENCE")
    bpy.ops.object.modifier_add(type = "BOOLEAN")
    handle = bpy.context.active_object.modifiers[0]
    handle.operation = "DIFFERENCE"
    handle.solver = solver
    handle.object = obj
    bpy.ops.object.modifier_set_active(modifier = handle.name)
    bpy.ops.object.modifier_apply(modifier = handle.name)
    bpy.ops.object.select_all(action = "DESELECT")
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.delete()
    bpy.data.meshes.remove(bpy.data.meshes[tmp_name])
    bpy.ops.object.select_all(action = "DESELECT")
    region.select_set(True)
    bpy.context.view_layer.objects.active = region
    return region

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
    ie = it1
    
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

def make(name, data):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(*(data[0:3]))
    mesh.update()
    
    obj = bpy.data.objects.new(name, mesh)
    """
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
    """
    
    scene = bpy.context.scene.collection.children[0]
    scene.objects.link(obj)
    bpy.ops.object.select_all(action = "DESELECT") # implicit
    obj.select_set(True) # additional select
    bpy.context.view_layer.objects.active = obj # not necessary
    return obj

try:
    redprint("Decoding Encrypted Engram", "...")
    #grid = make("Grid", Grid())
    #arc = make("Arc", Arc())
    #orb = make("Orb", Orb())
    seg = Tectum("Region")
    redprint("Master Rahool is finished", ".")
except Exception as e:
    error(e)