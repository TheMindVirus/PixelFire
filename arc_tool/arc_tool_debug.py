import math

def radians(degrees):
    return (degrees * math.pi) / 180

def sin(degrees):
    return math.sin(radians(degrees))

def cos(degrees):
    return math.cos(radians(degrees))

def tan(degrees):
    return math.tan(radians(degrees))

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

print(Rotate(1.0, 1.0, 1.0, 15.0, 15.0, 0.0, 0.0, 0.0, 0.0))
