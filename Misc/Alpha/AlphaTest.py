data = "# Auto-Generated File (Please do not edit)\n[0]\n"

w = 8
h = 8
d = 8
t = w * h * d

x = 0
y = 0
z = 0

r = 0
g = 0
b = 0
a = 0

for i in range(0, t):
    a = int((((x + 1) * (y + 1) * (z + 1)) / t) * 0xFF)
    data += "{},{},{},{},{},{},{:02X}\n".format(x, y, z, r, g, b, a)
    x += 1
    if x >= w:
        x = 0
        y += 1
        if y >= h:
            y = 0
            z += 1
            if z >= d:
                z = 0
                y = 0
                x = 0

file = open("AlphaTest.txt", "w")
file.write(data)
file.close()

print("Done!")
