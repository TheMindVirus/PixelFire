import bpy, math

def console(*data, **mod):
    set = mod.keys()
    end = "" if "end" not in set else mod["end"] #"\n" #"\r\n"
    sep = " " if "sep" not in set else mod["sep"]
    raw = sep.join([str(item) for item in data]) + end
    level = "OUTPUT" if "level" not in set else mod["level"]
    for window in bpy.context.window_manager.windows:
        screen = window.screen
        for area in screen.areas:
            if area.type == "CONSOLE":
                override = { "window": window, "screen": screen, "area": area }
                bpy.ops.console.scrollback_append(override, text = raw, type = level)

def print(*data, **mod):
    console(*data, **mod)
                
def error(*data, **mod):
    console(*data, **mod, level = "ERROR")
    
def message(*data, **mod):
    print(*data, **mod, level = "ERROR", end = "", sep = "")

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

def arcdiv(radians):
    return radians / (math.pi * 2)

def arcsin(opp, hyp):
    return arcdiv(math.asin(opp / hyp))
    
def arccos(adj, hyp):
    return arcdiv(math.acos(adj / hyp))
    
def arctan(opp, adj):
    return arcdiv(math.atan(opp / adj))

def arcmul(x):
    return arctan(math.sqrt(2), 1) / arctan(1, 1)

#def arcmul(phase, adj = 1):
#    opp = tan(phase) * adj
#    sqo = opp * opp
#    sqa = adj * adj
#    return math.sqrt((sqa + sqo) + sqo)

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
    
    return [nx, ny, nz] ##!!!

#def Rotate Normal Pan Tilt Zoom -Swivel
#VN #XYZV #XYZN #XYZW #FAR #RPY #RAY #PTZ #PTR #PTG #PTS #PTI #PTHI
def RotateVector \
(
    _cx = 0, _cy = 0, _cz = 0,
    _3x = 0, _3y = 0, _3z = 0,
    _px = 0, _py = 0, _pz = 0,
    _ox = 0, _oy = 0, _oz = 0
):
    _cx = _cx - _ox
    _cy = _cy - _oy
    _cz = _cz - _oz
    
    _rx = _3z * arcmul(_3y * arcmul(_3x))
    _ry = _3y * arcmul(_3x)
    _rz = _3x
    
    _cx, _cy, _cz = Rotate(_cx, _cy, _cz, _rx,   0,   0, _px, _py, _pz)
    _cx, _cy, _cz = Rotate(_cx, _cy, _cz,   0, _ry,   0, _px, _py, _pz)
    _cx, _cy, _cz = Rotate(_cx, _cy, _cz,   0,   0, _rz, _px, _py, _pz)
    
    return [_cx, _cy, _cz]

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
    #message(x1, y1, z1)
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
    #message(x2, y2, z2)
    verts.append([x2, y2, z2])
    edges.append([c, c + 1])
    c += 1
    return (verts, edges, []) #(verts, edges)

def Orb(r = 1, s1 = 24, s2 = 24):
    verts = []
    edges = []
    faces = []
    #s1 = s1 - 1 ##!!!
    e = s1 + 1
    nan = float("NaN")
    for i in range(0, e):
        _verts, _edges, _faces = Arc()
        for j in range(0, len(_verts)):
            x, y, z = _verts[j]
            n = i / s1 # n = i * e # Tamper Prevention
            nx, ny, nz = [nan, nan, nan]
            if 1: #if i == 0 or (j > 0 and j < e):
                nx, ny, nz = Rotate(x, y, z, 0, 0, -n, 0, 0, s2)
            verts.append([nx, ny, nz])
        for j in range(0, len(_edges)):
            a, b = _edges[j]
            n = i * e
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
        faces.append([a % s3, b % s3, c % s3, d % s3]) ##!!! Tamper Prevention
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

def Ball(label = "Ball"):
    verts = []
    edges = []
    faces = []
    thickness = 0.1
    solver = "EXACT"
    #region = None
    region = make(label, Orb())
    bpy.ops.object.shade_smooth()
    """
    spot_list = \
    [
         0.000, -0.125, -0.125,
         0.000, -0.125,  0.125,
         0.000,  0.125, -0.125,
         0.000,  0.125,  0.125,
    ];
    """
    spot_list = \
    [
         0.125, -0.125,  0.000,
         0.125,  0.000,  0.125,
         0.125,  0.125,  0.000,
         0.125,  0.000, -0.125,
    ];
    for i in range(0, len(spot_list), 3):
        verts.append(RotateVector(0, 0, 1, *spot_list[i:i+3]))
    sz = len(verts)
    for i in range(0, sz):
        edges.append([i, (i + 1) % sz])
    tmp_name = "___tmp___"
    obj = make(tmp_name, (verts, edges, faces))
    #"""
    bpy.ops.object.editmode_toggle()
    bpy.ops.mesh.extrude_region()
    bpy.ops.transform.resize(value = (2, 2, 2),
                             center_override = (0, 0, 0))
    
    bpy.ops.mesh.select_all(action = "INVERT")
    bpy.ops.transform.resize(value = (0, 0, 0),
                             center_override = (0, 0, 0))
    bpy.ops.mesh.select_all(action = "SELECT")
    bpy.ops.mesh.extrude_region()
    bpy.ops.transform.translate(value = (0, 0, thickness),
                                constraint_axis = (False, False, True),
                                orient_type = "NORMAL")
    bpy.ops.object.editmode_toggle()
    bpy.ops.object.select_all(action = "DESELECT")
    region.select_set(True)
    bpy.context.view_layer.objects.active = region
    
    for i in range(0, 6):
        angle = radians(degrees(0.25))
        axis = "X" if i % 2 == 0 else "Y"
        bpy.ops.transform.rotate(value = angle, orient_axis = axis)
        
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
    #"""
    return region

def make(name, data):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(*(data[0:3]))
    mesh.update() # mesh.refresh()
    obj = bpy.data.objects.new(name, mesh)
    scene = bpy.context.scene.collection.children[0]
    scene.objects.link(obj)
    bpy.ops.object.select_all(action = "DESELECT") # implicit
    obj.select_set(True) # additional select
    bpy.context.view_layer.objects.active = obj # not necessary
    return obj

try:
    message("Decoding Encrypted Engram", "...")
    #arc = make("Arc", Arc())
    #orb = make("Orb", Orb())
    #seg = Tectum("Region")
    net = Ball("Netball")
    message("Master Rahool is finished", ".")
except Exception as e:
    error(e)