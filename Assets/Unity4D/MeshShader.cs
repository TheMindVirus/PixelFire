using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class MeshShader : MonoBehaviour
{
    public ComputeShader shader;
    public GameObject debug;
    ComputeBuffer verts;
    Mesh meshIn;
    Mesh meshOut;
    int idx;

    string kernel = "main";
    string sizeName = "size";
    string rotationName = "rotation";
    string morphName = "morph";
    string debugRotationName = "_DebugRotation";
    string debugMorphName = "_DebugMorph";
    string vertsName = "verts";

    float fps = 1.0f;
    float time = 0.0f;
    float thresh = 1.0f;

    void Update()
    {
        thresh = 1.0f / fps;
        time += Time.deltaTime;
        if (time > thresh) { Run(); }
    }

    void Run()
    {
        if ((!SystemInfo.supportsComputeShaders) || (shader == null) || (!shader.HasKernel(kernel))) { return; }
        idx = shader.FindKernel(kernel);
        meshIn = GetComponent<MeshFilter>().sharedMesh;
        verts = new ComputeBuffer(meshIn.vertices.Length * 3, 4, ComputeBufferType.Raw, ComputeBufferMode.SubUpdates);
        verts.SetData(meshIn.vertices);
        shader.SetInt(sizeName, meshIn.vertices.Length);
        shader.SetVector(rotationName, GetComponent<MeshRenderer>().sharedMaterial.GetVector(debugRotationName));
        shader.SetVector(morphName, GetComponent<MeshRenderer>().sharedMaterial.GetVector(debugMorphName));
        shader.SetBuffer(idx, vertsName, verts);
        shader.Dispatch(idx, 1, 1, 1);
        Vector3[] v = new Vector3[meshIn.vertices.Length];
        verts.GetData(v);
        //Debug.Log(v[0]);
        meshOut = new Mesh();
        meshOut.name = name;
        meshOut.vertices = v;
        meshOut.triangles = meshIn.triangles;
        //Debug.Log(meshIn.vertices.Length);
        //mesh.RecalculateNormals();
        GetComponent<MeshCollider>().sharedMesh = meshOut;
        //if (debug != null) { debug.GetComponent<MeshFilter>().mesh = meshOut; }
        verts.Release();
    }
}
