size = 2
frames = 2

def PixelFire(data, F, X, Y, Z, R, G, B, A):
    index = (F * size * size * size * 4) \
          + (X * size * size * 4) \
          + (Y * size * 4) \
          + (Z * 4)
    data[index + 0] = R
    data[index + 1] = G
    data[index + 2] = B
    data[index + 3] = A
    return data

data = [0] * (frames * size * size * size * 4)
print("".join("{:02X} ".format(i) for i in data))
for i in range(0, frames * size * size * size):
    z = int(i / pow(size, 0)) % size
    y = int(i / pow(size, 1)) % size
    x = int(i / pow(size, 2)) % size
    f = int(i / pow(size, 3)) % size
    print(f, x, y, z)
    data = PixelFire(data, f, x, y, z, i, i, i, i)
print("".join("{:02X} ".format(i) for i in data))
for i in range(0, frames * size * size * size):
    z = int(i / pow(size, 0)) % size
    y = int(i / pow(size, 1)) % size
    x = int(i / pow(size, 2)) % size
    f = int(i / pow(size, 3)) % size
    j = int((x * size * size) + (y * size) + (z))
    print(z, y, x, f, j)
    print(j / size / size / size)
    print(data[j*4:j*4+4])
