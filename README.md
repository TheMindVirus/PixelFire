# PixelFire
3D Video Codec for playing back pre-rendered Voxel Animations in Unity with Volumetric Shaders (WIP)

# Format
```
[0]
X, Y, Z, R, G, B, A
X, Y, Z, R, G, B, A
```

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