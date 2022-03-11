using System;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class PixelFireMod : MonoBehaviour
{
    [MenuItem("Assets/Convert PixelFire to Texture3D's")]
    static void ConvertPixelFireToTexture3DsMethod(MenuCommand menuCommand)
    {
        string guid = Selection.assetGUIDs[0];
        string path = AssetDatabase.GUIDToAssetPath(guid);
        string here = Path.GetDirectoryName(path);
        string call = Path.GetFileNameWithoutExtension(path);
        string data = File.ReadAllText(path, Encoding.UTF8);

        int frames = 0;
        int errors = 0;
        int thisln = 0;
        List<Texture3D> tex = new List<Texture3D>();

        foreach (string currentLine in data.Split('\n'))
        {
            ++thisln;
            string line = currentLine;
            line = line.Split(new string[1] { "//" }, StringSplitOptions.None)[0];
            line = line.Split('#')[0];
            line = line.Replace(" ", "");
            line = line.Replace("\r", "");
            if (line.StartsWith("["))
            {
                tex.Add(new Texture3D(8, 8, 8, TextureFormat.RGBA32, true)); //!!! Fixed Size !!!
                tex[frames].SetPixels32(new Color32[8 * 8 * 8], 0); //!!! Only First Frame !!!
                tex[frames].filterMode = FilterMode.Point;
                ++frames;
                continue;
            }
            string[] command = line.Split(',');
            if (command.Length == 7)
            {
                try
                {
                    int x = Convert.ToInt32(command[0], 16);
                    int y = Convert.ToInt32(command[1], 16);
                    int z = Convert.ToInt32(command[2], 16);
                    Color rgba = new Color();
                    rgba.r = Convert.ToSingle(Convert.ToInt32(command[3], 16)) / 255.0f;
                    rgba.g = Convert.ToSingle(Convert.ToInt32(command[4], 16)) / 255.0f;
                    rgba.b = Convert.ToSingle(Convert.ToInt32(command[5], 16)) / 255.0f;
                    rgba.a = Convert.ToSingle(Convert.ToInt32(command[6], 16)) / 255.0f;
                    int l = frames - 1;
                    tex[l].SetPixel(x, z, y, rgba, 0);
                }
                catch (Exception error)
                {
                    if (errors == 0)
                    {
                        Debug.Log("[PixelFire]: " + error.GetType().Name + ": " + error.Message + "\n" + error.StackTrace);
                    }
                    ++errors;
                }
            }
            else
            {
                if (command[0].Length != 0)
                {
                    if (errors == 0) { Debug.Log("[PixelFire]: Unknown Format at Line " + thisln.ToString()); }
                    ++errors;
                }
            }
        }
        for (int i = 0; i < frames; ++i)
        {
            AssetDatabase.CreateAsset(tex[i], Path.Combine(here, call + i.ToString() + ".asset"));
        }
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("[PixelFire]: Encoded " + frames.ToString() + " Frames with " + errors.ToString() + " Known Errors");
    }
}
