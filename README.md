# PixelFire
3D Video Codec for playing back pre-rendered Voxel Animations in Unity with Volumetric Shaders (WIP)

### New Features
```
* Updated Volumetric Shaders - Now Appears in Play Mode (still no forward lighting though...)
* PixelFireMod.cs - Modded PixelFire to Texture3D Conversion Script to make a Texture3D per detected frame
* FireDeck - Texture3D Animation Playback script with Live Editor Scrubbing
```

PixelFire files can take any file extension e.g. .txt is used to open it in Notepad, text/pixelfire for MIME \
and PixelFire Transcode (.pft) formerly belonged to a scientific word processor for MS-DOS called ChiWriter.

### Usage
```
* To start, write your own version of PixelFire.txt in your favourite text editor (stick carefully to the format)
* Add your new animation file to Unity in the Assets folder, right click it and select "Convert PixelFire to Texture3D's"
* If the conversion completed successfully, you should now have each frame of your animation as a Texture3D
* Add a new Cube to the scene, give it a New Material and add the ProperVolumeShader to that Material
* Add the FireDeck script to the cube by using Click and Drag from Assets to the Hierarchy or to the Inspector
* Expand the Frames property, Increase the Size from 0 and Click and Drag your Texture3D's into the empty slots
* Optionally, Change the Frames Per Second, Scrub to the Desired Current Frame in the Editor and Mod the Script itself
* Hit Play to make sure the Render Queue is set up correctly to "From Shader" and "Transparent+1" (3001)
* Check for Alpha Defects and other Bugs and Keep Modding the Scripts to Find Solutions for these Issues
```

![screenshot](https://github.com/TheMindVirus/PixelFire/blob/firedeck/screenshot1.png)
![screenshot](https://github.com/TheMindVirus/PixelFire/blob/firedeck/screenshot2.png)

### *Not many experiments start off with the words, "I've just set fire to a turd, now to record it."*
</br>

![screenshot](https://github.com/TheMindVirus/PixelFire/blob/main/screenshot4.png)
![screenshot](https://github.com/TheMindVirus/PixelFire/blob/main/screenshot5.png)
