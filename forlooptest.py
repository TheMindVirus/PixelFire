x = 0
y = 0
z = 0

size = 2

for i in range(0, size * size * size):
    print(z, y, x, i)
    x += 1
    if x >= size:
        x = 0
        y += 1
        if y >= size:
            y = 0
            z += 1
            if z >= size:
                break
