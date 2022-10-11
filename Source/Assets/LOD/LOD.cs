using UnityEngine;

public class Swarm : MonoBehaviour
{
    public Transform prefab = null;
    public int instances = 5000;
    public float radius = 50f;

    void Start()
    {
        if (prefab == transform) { Debug.Log("[WARN]: Recursive Operation Detected"); return; }
        for (int i = 0; i < instances; ++i)
        {
            Transform t = Instantiate(prefab);
            t.localPosition = Random.insideUnitSphere * radius;
            t.SetParent(transform);
        }
    }
}
