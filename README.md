# PixelFire - blender (Experimental)
3D Video Codec for playing back pre-rendered Voxel Animations in Blender 2.93 and associated Python 3.9.2 (WIP)

![screenshot](https://github.com/TheMindVirus/PixelFire/blob/blender/screenshot.png)
![screenshot](https://github.com/TheMindVirus/PixelFire/blob/blender/screenshot1.png)
![screenshot](https://github.com/TheMindVirus/PixelFire/blob/blender/screenshot2.png)
![screenshot](https://github.com/TheMindVirus/PixelFire/blob/blender/screenshot3.png)

## Issues
```
* Alpha Channel from PixelFire format ignored due to inaccurate Blending in Blender EEVEE Shaders
* PixelFire format is new and currently doesn't encode all of bpy.types.Image's properties e.g. width * height * depth
* Alpha Blending is Visibly Incorrect, Normals have to be flipped for Front-face Culling and Volumetric Shaders
* Fragments over-rendered due to cubes having 4,096 vertices, 3,072 faces and 6,144 triangles
* Every Single Face Normal was specified in reverse order resulting in flipped normals which had to be flipped back afterwards
* PixelFire's Multi-Frame support still needs to be correctly plugged in to Blender's Multiple-Keyframe support for FBX export
* Converted PixelFire Transcode file may appear incorrectly in Final Render and Texture Paint viewports (and in save files)
* UV Mapping is inaccurate due to the tiny floating point precision required to map 3D texture coordinates to 1D 0.0->1.0
* Blender engine code for loading vertices, edges, faces, uv's and normals is messy for the user to write and could be improved
* Process is not smooth, riddled with errors and is far from automated, the end product is pre-rendered on high-end PC hardware
```

## Future Work
```
* Fix the above issues and add automatic Keyframing to the codec scripts
* Wait for stable Blender LTS Updates (especially a sub-screen for Voxel Editing and resurrected Blender Game Engine)
* Test export to .FBX and see if the animation correctly imports into unity
```
### *Not many experiments start off with the words, "I've just set fire to a turd, now to record it."*
#### *![PFChangs.py](https://github.com/TheMindVirus/PixelFire/blob/blender/PFChangs.py), anyone?*
![screenshot](https://github.com/TheMindVirus/PixelFire/blob/main/screenshot4.png)
![screenshot](https://github.com/TheMindVirus/PixelFire/blob/main/screenshot5.png)
