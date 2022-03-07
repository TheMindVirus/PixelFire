# PixelFire GLSL Branch
3D Video Codec for playing back pre-rendered Voxel Animations in Unity with Volumetric Shaders (WIP)

## Format
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

![screenshot](https://github.com/TheMindVirus/PixelFire/blob/glsl/screenshot.png)

## Warbling
It was found during development that forgetting to `#include "UnityCG.glslinc"` \
left things like the camera position and object-local view direction undefined.

Adding this include fixed a lot of problems but also produced Warbling artifacts \
on the camera. This was caused by calling `normalize()` to clamp the direction to 1.0.

The issue occurred only when the object-local view direction was being calculated from \
the Vertex Shader and not the Fragment Shader (where `ObjSpaceViewDir()` needed redefining).

Please see the following Pull Request for more information: \
https://github.com/TwoTailsGames/Unity-Built-in-Shaders/pull/4

![screenshot](https://github.com/TheMindVirus/PixelFire/blob/glsl/screenshot2.png)
![screenshot](https://github.com/TheMindVirus/PixelFire/blob/glsl/screenshot3.png)

## Issues
```
* Alpha Channel from PixelFire format ignored due to inaccurate Blending in Unity Shaders
* PixelFire format is new and currently doesn't encode all of Texture3D's properties e.g. width * height * depth
* `Blend SrcAlpha OneMinusSrcAlpha` is an invalid but standard Blend Mode for Transparency on Modern GPU's
* `fragment = (previous + source) * 0.5` is the correct method for blending but is not implemented properly
* `alpha = preva + ((1.0 - preva) + srca)` is the correct occlusion model but only if the ray comes from the camera
* Calling `normalize()` after `ObjSpaceViewDir()` from Vertex Shader has Warbling artifacts not present in Fragment Shader
* Fragments over-rendered due to cubes having 6 sides, 6/12 faces and 8 vertices
* Origin for ray tracing introduces slight error for correct functionality and requires 3090(Ti) unrolled iterations
* Starting direction of ray tracing is not always from the camera, is sometimes calculated across direction of normals
* LOD and Mipmaps are inaccurate terms to be replaced by Subtexture where a Texture is XYZRGBA Float32
* Using LOD for storing additional frames of video is scuppered by mipmaps automatically downscaling each frame by x2
* `tex3D` should be used in all cases instead of `tex3lod` as downscaling wrecks performance
* Specifying the RenderQueue as 3001 in SubShader Tags fixes Transparency Glitches but is only allowed for HDRP/URP
* Process is not smooth, riddled with errors and is far from automated but the end product is realtime on potato hardware
```

## Future Work
```
* Fix the above issues and add Metadata to the codec scripts
* Reimplement OneMinusSource as the following:
 - Data: 0.4, 0.6, 0.5
 - Stage0: 0.4 = 0.4
 - Stage1: 0.4 + (1.0 - 0.4) + 0.6 = 1.6
 - Stage2: 0.4 + (1.0 - 0.4) + 0.6 + (1.0 - 0.6) + 0.5 = 2.5
 - The Integral Part is the Stage and the Fractional Part is the Value
 - Except Value = 0.0 where Stage -= 1 and Value += 1 (Detected by Stage != PreviousStage + 1)
* Wait for Unity Updates (especially VFX Graph and HDRP WebGL Build Compatibility)
* Add more options for Lighting Model e.g. Standard rather than just Off
```
### *Not many experiments start off with the words, "I've just set fire to a turd, now to record it."*
</br>

![screenshot](https://github.com/TheMindVirus/PixelFire/blob/main/screenshot4.png)
![screenshot](https://github.com/TheMindVirus/PixelFire/blob/main/screenshot5.png)
