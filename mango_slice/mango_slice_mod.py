import bpy, math

def console(*args, **kwargs):
    set = kwargs.keys()
    end = "" if "end" not in set else kwargs["end"]
    sep = " " if "sep" not in set else kwargs["sep"]
    raw = sep.join([str(item) for item in args]) + end
    level = "OUTPUT" if "level" not in set else kwargs["level"]
    for window in bpy.context.window_manager.windows:
        screen = window.screen
        for area in screen.areas:
            if area.type == "CONSOLE":
                override = { "window": window, "screen": screen, "area": area }
                bpy.ops.console.scrollback_append(override, text = raw, type = level)

def print(*args, **kwargs):
    console(*args, **kwargs)
                
def error(*args, **kwargs):
    console(*args, **kwargs, level = "ERROR")
    
def message(*args, **kwargs):
    print(*args, **kwargs, level = "ERROR", end = "", sep = "")

def radians(degrees):
    return (degrees * math.pi) / 180

def degrees(phase):
    return (phase * 360)

def phase(degrees_list):
    phase_list = []
    for i in range(0, len(degrees_list)):
        phase_list.append(degrees_list[i] / 360)
    return phase_list

def csc(phase):
    return 1.0 / math.sin(radians(degrees(phase)))

def sec(phase):
    return 1.0 / math.cos(radians(degrees(phase)))

def cot(phase):
    return 1.0 / math.tan(radians(degrees(phase)))

def make(name, data):
    mesh = bpy.data.meshes.new(name)
    mesh.from_pydata(*(data[0:3]))
    mesh.update() # mesh.refresh()
    obj = bpy.data.objects.new(name, mesh)
    scene = bpy.context.scene.collection.children[0]
    scene.objects.link(obj)
    if (bpy.context.mode != "OBJECT"):
        bpy.ops.object.mode_set(mode = "OBJECT", toggle = False) # extraneous
    bpy.ops.object.select_all(action = "DESELECT") # implicit
    obj.select_set(True) # additional select
    bpy.context.view_layer.objects.active = obj # not necessary
    return obj

def get_face_count():
    tmp_mode = bpy.context.mode
    if tmp_mode == "EDIT_MESH":
        tmp_mode = "EDIT"
    bpy.ops.object.mode_set(mode = "OBJECT")
    obj = bpy.context.active_object
    count = len(obj.data.polygons)
    bpy.ops.object.mode_set(mode = tmp_mode)
    return count

def select_face_by_index(index = 0, select = True):
    tmp_mode = bpy.context.mode
    if tmp_mode == "EDIT_MESH":
        tmp_mode = "EDIT"
    bpy.ops.object.mode_set(mode = "OBJECT")
    obj = bpy.context.active_object
    i = 0
    for face in obj.data.polygons:
        if i == index:
            face.select = select
            break
        i += 1
    bpy.ops.object.mode_set(mode = tmp_mode)

#def select_faces_by_index(index = [], select = []):
#    for i in range(0, len(index)):
#        select_face_by_index(index[i], select[i])

def mesh_make_edge(x, y):
    pass
    print("mesh_make_edge")
    tmp_mode = bpy.context.mode
    if tmp_mode == "EDIT_MESH":
        tmp_mode = "EDIT"
    bpy.ops.object.mode_set(mode = "OBJECT")
    obj = bpy.context.active_object
    for i in range(0, len(obj.data.vertices)):
        if x != None and obj.data.vertices[i].co == x.co:
            print("x found")
            obj.data.vertices[i].select = True
        elif y != None and obj.data.vertices[i].co == y.co:
            print("y found")
            obj.data.vertices[i].select = True
    bpy.ops.object.mode_set(mode = "EDIT")
    try:
        bpy.ops.mesh.edge_face_add()
    except Exception as error:
        print("[WARN]:", error)
    bpy.ops.mesh.select_all(action = "DESELECT")
    bpy.ops.object.mode_set(mode = tmp_mode)

def mesh_make_face(a, b, c, d = None):
    pass
    #print("mesh_make_face")
    tmp_mode = bpy.context.mode
    if tmp_mode == "EDIT_MESH":
        tmp_mode = "EDIT"
    bpy.ops.object.mode_set(mode = "OBJECT")
    obj = bpy.context.active_object
    for i in range(0, len(obj.data.vertices)):
        if a != None and obj.data.vertices[i].co == a.co:
            #print("a found")
            obj.data.vertices[i].select = True
        elif b != None and obj.data.vertices[i].co == b.co:
            #print("b found")
            obj.data.vertices[i].select = True
        elif c != None and obj.data.vertices[i].co == c.co:
            #print("c found")
            obj.data.vertices[i].select = True
        elif d != None and obj.data.vertices[i].co == d.co:
            #print("d found")
            obj.data.vertices[i].select = True
    bpy.ops.object.mode_set(mode = "EDIT")
    try:
        bpy.ops.mesh.edge_face_add()
    except Exception as error:
        pass
        #print("[WARN]:", error)
    bpy.ops.mesh.select_all(action = "DESELECT")
    bpy.ops.object.mode_set(mode = "OBJECT")

def mesh_make_surf(index = []):
    pass
    print("mesh_make_surf")
    tmp_mode = bpy.context.mode
    if tmp_mode == "EDIT_MESH":
        tmp_mode = "EDIT"
    bpy.ops.object.mode_set(mode = "OBJECT")
    obj = bpy.context.active_object
    for i in range(0, len(obj.data.vertices)):
        for j in index:
            if j != None and obj.data.vertices[i].co == j.co:
                print(j, "found")
                obj.data.vertices[i].select = True
    bpy.ops.object.mode_set(mode = "EDIT")
    try:
        bpy.ops.mesh.edge_face_add()
    except Exception as error:
        print("[WARN]:", error)
    bpy.ops.mesh.select_all(action = "DESELECT")
    bpy.ops.object.mode_set(mode = "OBJECT")

def mesh_connect_all(limit = 1000):
    print("mesh_connect_all")
    tmp_mode = bpy.context.mode
    if tmp_mode == "EDIT_MESH":
        tmp_mode = "EDIT"
    bpy.ops.object.mode_set(mode = "OBJECT")
    obj = bpy.context.active_object
    vex = obj.data.vertices
    i = 0
    for j in vex:
        for k in vex:
            if j != k:
                pass
                #mesh_make_edge(j, k)
                #mesh_make_surf([j, k])
            for l in vex:
                for m in vex:
                    if j != k \
                    and k != l \
                    and l != m \
                    and m != j \
                    and j != l \
                    and k != m:
                        pass
                        if i >= limit:
                            break
                        mesh_make_face(j, k, l, m)
                        #mesh_make_surf([j, k, l, m])
                        i += 1
    bpy.ops.object.mode_set(mode = tmp_mode)

def Mango(label = "Mango", dimension = 3, connect = False, limit = 100):
    verts = []
    edges = []
    faces = []
    verts.append([0.0, 0.0, 0.0])
    region = make(label, (verts, edges, faces))
    bpy.ops.object.mode_set(mode = "EDIT")
    bpy.ops.mesh.select_mode(type = "VERT")
    #bpy.ops.object.editmode_toggle()
    #bpy.ops.object.select_mode(type = "EDIT")
    #bpy.ops.mesh.select_mode(type = "VERTEX")
    for i in range(1, dimension + 1):
        print("Dimension", i)
        if i == 1:
            bpy.ops.mesh.select_all(action = "SELECT")
            bpy.ops.mesh.extrude_region()
            bpy.ops.transform.translate(value = (2, 0, 0),
                   constraint_axis = (True, False, False),
                                  orient_type = "NORMAL")
            bpy.ops.mesh.select_all(action = "SELECT")
            bpy.ops.transform.translate(value = (-1, 0, 0),
                    constraint_axis = (True, False, False),
                                   orient_type = "GLOBAL")
        elif i == 2:
            bpy.ops.mesh.select_all(action = "SELECT")
            bpy.ops.mesh.extrude_region()
            bpy.ops.transform.translate(value = (0, 2, 0),
                   constraint_axis = (False, True, False),
                                  orient_type = "GLOBAL")
            bpy.ops.mesh.select_all(action = "SELECT")
            bpy.ops.transform.translate(value = (0, -1, 0),
                    constraint_axis = (False, True, False),
                                   orient_type = "GLOBAL")
        elif i == 3:
            bpy.ops.mesh.select_face_by_sides(0)
            bpy.ops.mesh.extrude_region()
            bpy.ops.transform.translate(value = (0, 0, 2),
                   constraint_axis = (False, False, True),
                                  orient_type = "NORMAL")
            bpy.ops.mesh.select_all(action = "SELECT")
            bpy.ops.transform.translate(value = (0, 0, -1),
                    constraint_axis = (False, False, True),
                                   orient_type = "GLOBAL")
        else:
            bpy.ops.mesh.select_all(action = "DESELECT")
            bpy.ops.mesh.select_mode(type = "FACE")
            sides = get_face_count()
            for j in range(0, sides):
                 select_face_by_index(j)
                 bpy.ops.mesh.extrude_region()
                 bpy.ops.transform.translate(value = (0, 0, 2),
                       constraint_axis = (False, False, False),
                                       orient_type = "NORMAL")
                 select_face_by_index(j, False)
                 bpy.ops.mesh.select_all(action = "DESELECT")
            bpy.ops.mesh.select_mode(type = "VERT")
            if connect:
                mesh_connect_all(limit = limit)
    ##bpy.ops.object.editmode_toggle()
    ##bpy.ops.mesh.select_mode(type = "VERTEX")
    ##bpy.ops.object.select_mode(type = "OBJECT")
    bpy.ops.mesh.select_mode(type = "VERT")
    bpy.ops.object.mode_set(mode = "OBJECT")
    bpy.context.view_layer.objects.active = region
    return region

try:
    message("Decoding Encrypted Engram", "...")
    net = Mango("Mango", 4)
    #net = Mango("Mango", 5, True, 100)
    message("Master Rahool is finished", ".")
except Exception as e:
    error(e)