using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireDeck : MonoBehaviour
{
    public List<Texture3D> Frames = new List<Texture3D>();
    public int Scrub = 0;
    public float FPS = 15.0f;
    private float currentTime = 0.0f;
    private float previousTime = 0.0f;

    private int ScrubLast = 0;

    void OnValidate()
    {
        if (Scrub != ScrubLast)
        {
            if ((Scrub >= 0) && (Scrub < Frames.Count))
            {
                GetComponent<MeshRenderer>().sharedMaterial.SetTexture("_Texture", Frames[Scrub]);
            }
            ScrubLast = Scrub;
        }
    }

    void Update()
    {
        currentTime = Time.time;
        if ((currentTime > (previousTime + (1.0 / FPS))) && (Frames.Count > 0))
        {
            ++Scrub; if (Scrub > Frames.Count) { Scrub = 0; }
            GetComponent<MeshRenderer>().sharedMaterial.SetTexture("_Texture", Frames[Scrub]);
            previousTime = currentTime;
        }
    }
}
