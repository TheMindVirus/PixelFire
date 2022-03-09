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
data = PixelFire(data, 0, 0, 0, 0, 255, 255, 255, 255)
print("".join("{:02X} ".format(i) for i in data))
data = [0] * (frames * size * size * size * 4)
data = PixelFire(data, 0, 1, 1, 1, 255, 255, 255, 255)
print("".join("{:02X} ".format(i) for i in data))
data = [0] * (frames * size * size * size * 4)
data = PixelFire(data, 1, 0, 0, 0, 255, 255, 255, 255)
print("".join("{:02X} ".format(i) for i in data))
data = [0] * (frames * size * size * size * 4)
data = PixelFire(data, 1, 1, 1, 1, 255, 255, 255, 255)
print("".join("{:02X} ".format(i) for i in data))
