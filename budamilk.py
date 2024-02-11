file = open("budamilk.svg", "rb")
data = file.read()
file.close()

newdata = b""
for line in data.split(b"\r\n"):
    newline = line
    newline = newline.replace(b"\"", b"\\\"")
    newline += b"\\r\\n\\\n"
    newdata += newline

file = open("budamilk.txt", "wb")
file.write(newdata)
file.close()

print(len(newdata), "Bytes Written")

print("Done!")
