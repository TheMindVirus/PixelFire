using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class MeshShader : MonoBehaviour
{
    public ComputeShader shader;
    public GameObject debug;
    ComputeBuffer verts;
    ComputeBuffer tris;
    Texture tex;
    Mesh mesh;
    int idx;
    int grand;
    int total;

    string kernel = "main";
    string texName = "tex";
    string vertsName = "verts";
    string trisName = "tris";
    string textureName = "_Texture";

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
        shader.GetKernelThreadGroupSizes(idx, out uint x, out uint y, out uint z);
        grand = (int)(x * y * z);
        total = grand * 3 * 12;
        tex = GetComponent<MeshRenderer>().sharedMaterial.GetTexture(textureName);
        verts = new ComputeBuffer(total * 3, 4, ComputeBufferType.Raw, ComputeBufferMode.SubUpdates);
        tris = new ComputeBuffer(total * 1, 4, ComputeBufferType.Raw, ComputeBufferMode.SubUpdates);
        Vector3[] v = new Vector3[total];
        int[] t = new int[total];
        verts.SetData(v);
        tris.SetData(t);
        shader.SetTexture(idx, texName, tex);
        shader.SetBuffer(idx, vertsName, verts);
        shader.SetBuffer(idx, trisName, tris);
        shader.Dispatch(idx, (int)x, (int)y, (int)z);
        verts.GetData(v);
        tris.GetData(t);
        //Debug.Log(v[0]);
        //Debug.Log(t[0]);
        mesh = new Mesh();
        mesh.Clear();
        mesh.name = name;
        mesh.vertices = v;
        mesh.triangles = t;
        //Debug.Log(mesh.vertices.Length);
        //Debug.Log(mesh.triangles.Length);
        //mesh.RecalculateNormals();
        GetComponent<MeshFilter>().mesh = mesh;
        GetComponent<MeshCollider>().sharedMesh = mesh;
        //if (debug != null) { debug.GetComponent<MeshFilter>().mesh = mesh; }
        verts.Release();
        tris.Release();
    }
}
