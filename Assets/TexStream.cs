using UnityEngine;

public class TexStream : MonoBehaviour
{
    public int size = 8;
    Texture3D tex = null;

    void Update()
    {
        tex = new Texture3D(size, size, size, TextureFormat.RGBA32, false);
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Point;
        Color[] colors = new Color[size * size * size];
        for (int z = 0; z < size; ++z)
        {
            int zo = z * size * size;
            for (int y = 0; y < size; ++y)
            {
                int yo = y * size;
                for (int x = 0; x < size; ++x)
                {
                    colors[x + yo + zo] = new Color(Random.Range(0.0f, 1.0f),
                                                    Random.Range(0.0f, 1.0f),
                                                    Random.Range(0.0f, 1.0f), 
                                                    Random.Range(0.0f, 1.0f));
                }
            }
        }
        tex.SetPixels(colors);
        tex.Apply();
        transform.GetComponent<MeshRenderer>().material.SetTexture("_MainTex", tex);
    }
}