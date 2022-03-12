using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireDeckMod : MonoBehaviour
{
    public List<Texture3D> Frames = new List<Texture3D>();
    [Range(0.0f, 1.0f)] //Turns Scrub in to a Range Slider for SpaceDesk TouchScreens
    public float Scrub = 0.0f;
    public float FPS = 15.0f;
    private float currentTime = 0.0f;
    private float previousTime = 0.0f;

    private float ScrubLast = 0.0f;

    void OnValidate()
    {
        if (Scrub != ScrubLast)
        {
            if ((Scrub >= 0) && (Scrub < Frames.Count))
            {
                int frame = (int)(Scrub * (float)(Frames.Count - 1));
                GetComponent<MeshRenderer>().sharedMaterial.SetTexture("_Texture", Frames[frame]);
            }
            ScrubLast = Scrub;
        }
    }

    void Update()
    {
        currentTime = Time.time;
        if ((currentTime > (previousTime + (1.0 / FPS))) && (Frames.Count > 0))
        {
            Scrub += (1.0f / (float)(Frames.Count - 1)); if (Scrub > 1.0f) { Scrub = 0.0f; }
            int frame = (int)(Scrub * (Frames.Count - 1.0f));
            GetComponent<MeshRenderer>().sharedMaterial.SetTexture("_Texture", Frames[frame]);
            previousTime = currentTime;
        }
    }
}
