# pixelfire_pop
### 3D-PNG Support in Blender and Paint.NET for creating sliced 3D graphics overlays

## Instructions
```
1) Take a plan-view top-down screenshot of the object you want to scan
 - Optionally also take elevation shots or create it from scratch with pixel editors
2) Create multiple layers (usually 2-4 works best) and number the filenames in order
 - e.g. 1.png, 2.png, 3.png, etc... where 1 is the base layer and 2 onwards are for depth
3) Use Paint.NET to Alpha-key the background of the first layer so it is transparent
 - this will need "Overwrite" mode in the Fill tool's options
4) Continue Alpha-keying the other layers in order of depth until only pin headers remain
 - at each stage use the rectangle tool to select and contrast components from boards
5) Import them into Blender using "Images as Planes" and make sure "Alpha Blend" is on
 - using the node editor, make sure the image is applied to Base, Alpha and Emission
6) Stack each image layer multiple times to create multiple slices
 - a depth of 0.01 to 0.03 blender units for slice repeats of up to 3 times works best
 - you can repeat each layer as many times as you like to create realistic pin headers
7) Find a look and a camera angle that works best for your new 3D-PNG, save and export
 - also have a look at Emission Strength, Bloom and Specular options to get it just right
 - remember to "Pack all (images) into .blend" when saving so the images get saved properly
```
![pixelfire_pop](https://github.com/TheMindVirus/PixelFire/blob/pop/DHT22/screenshot.png)

![pixelfire_pop](https://github.com/TheMindVirus/PixelFire/blob/pop/HUB75/screenshot.png)

![pixelfire_pop](https://github.com/TheMindVirus/PixelFire/blob/pop/VEGA5/screenshot.png)