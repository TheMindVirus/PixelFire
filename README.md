# PixelFire
3D Video Codec for playing back pre-rendered Voxel Animations in Unity with Volumetric Shaders (WIP)

![screenshot](https://github.com/themindvirus/pixelfire/blob/main/screenshot.png)

# Format
```
#BEGIN_METADATA //Comment
#Key: Value //Comment
#END_METADATA //Comment
 //Comment
[0] //Comment
X, Y, Z, R, G, B, A //Comment
X, Y, Z, R, G, B, A //Comment
 //Comment
[1] //Comment
X, Y, Z, R, G, B, A //Comment
X, Y, Z, R, G, B, A //Comment
```

![screenshot](https://github.com/themindvirus/pixelfire/blob/main/screenshot1.png)

# Examples
#### General
```
[0]
5, 5, 5, 0, 0, 255, 127
5, 5, 6, 255, 0, 0, 64

[1]
6, 6, 6, 0, 0, 255, 127
5, 5, 5, 255, 0, 0, 64
```
#### Speed and Size
```[0]
0102030000FF7F
040506FF000040
```
#### Flexibility in Python
```py
data = \
"""
[Frame#]
"XZYARGB", X, Z, Y, A, R, G, B //Voxel 0
"XYZRGBA", X, Y, Z, R, G, B, A //Voxel 1
"""
```
#### Compatibility in Python 3.10
```py
fmt = ["X", "Y", "Z", "R", "G", "B", "A"]
data = \
{
    0: [ (fmt[:]), ([ 0, 0, 0, 0, 0, 0, 0 ]) ],
    1: [ (fmt[:]), ([ 0, 0, 0, 0, 0, 0, 0 ]) ],
}
>>> data[0][1][data[0][0].index("A")] = 255
>>> data[0][1][data[0][0].index("A")]
```
#### Ease of Use in Python
```py
fmt = "XYZRGBA"
data = \
[
    [0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0],
]
>>> data[0][6] = 255
>>> print(data)
```

![screenshot](https://github.com/themindvirus/pixelfire/blob/main/screenshot2.png)

# Issues
```
* Alpha Channel from PixelFire format ignored due to inaccurate Blending in Unity Shaders
* PixelFire format is new and currently doesn't encode all of Texture3D's properties e.g. width * height * depth
* `Blend SrcAlpha OneMinusSrcAlpha` is an invalid but standard Blend Mode for Transparency on Modern GPU's
* Black Spot at center of world when rendered with surface shader of which vertex shader is badly undocumented
* Fragments over-rendered due to cubes having 6 sides, 6/12 faces and 8 vertices
* Origin for ray tracing introduces slight error for correct functionality and requires 3090(Ti) unrolled iterations
* Starting direction of ray tracing is not always from the camera, is sometimes calculated across direction of normals
* LOD and Mipmaps are inaccurate terms to be replaced by Subtexture where a Texture is XYZRGBA Float32
* Using LOD for storing additional frames of video is scuppered by mipmaps automatically downscaling each frame by x2
* Process is not smooth, riddled with errors and is far from automated but the end product is realtime on potato hardware
```

![screenshot](https://github.com/themindvirus/pixelfire/blob/main/screenshot3.png)
![screenshot](https://github.com/themindvirus/pixelfire/blob/main/screenshot4.png)
