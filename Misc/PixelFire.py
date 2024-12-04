file = open("PixelFire.txt", "r")
data = file.read()
file.close()

newdata = ""
frame = -1

for line in data.split("\n"):
    try:
        if len(line) >= 3 and line[0] == "[":
            frame = int("".join([i for i in line if i in "0123456789.-"]))
            newdata += "[" + str(frame) + "]" + "\n"
        line = line.split("//")[0]
        line = line.split("#")[0]
        cmd = line.split(",")
        if len(cmd) == 7:
            for i in range(0, 7):
                value = int(cmd[i], 16)
                newdata += "{:02X}".format(value)
            newdata += "\n"
    except Exception as error:
        print(error)

file = open("PixelFire.compressed.txt", "w")
file.write(newdata)
file.close()
print("Done!")
