Shader "Custom/Colour"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Texture ("Texture", 2D) = "" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _DebugHue ("Hue", Float) = 0.0
        _DebugRadiance ("Radiance", Float) = 0.0
        _DebugValue ("Value", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }

        CGPROGRAM
// Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers d3d11 gles
        #pragma surface surface Standard vertex:vertex alpha:blend fullforwardshadows
        #pragma target 3.0

        #define PI 3.1415926
        #define N 3

        fixed4 _Color;
        sampler2D _MainTex;
        //float4 _MainTex_ST;
        sampler2D _Texture;
        float4 _Texture_ST;
        half _Glossiness;
        half _Metallic;
        float _DebugHue;
        float _DebugRadiance;
        float _DebugValue;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
            float4 color : COLOR;
            float4 screenPos;
            float3 worldPos;
            float3 worldRefl;
            float3 worldNormal;
            float3 vertex;
        };

        float AtanN(uint n)
        {
            if (n <= 1) { return 0; }
            float o = 45.0 * (PI / 180.0);
            if (n == 2) { return o; }
            for (uint i = 2; i < n; ++i)
            {
                o = atan(sin(o));
            }
            return o;
        }

        void RotateA(inout float v[N], uint n, float r, uint k)
        {
            float o[N];
            float z[N];
            for (uint i = 0; i < n; ++i)
            {
                z[i] = 0;
            }
            o = z;
            for (uint y = 0; y < n; ++y)
            {
                for (uint x = 0; x < n; ++x)
                {
                    if (x == y)
                    {
                        if (x == k) { o[k] = v[k]; }
                        else { o[y] += (v[y] * cos(r)); }
                    }
                    else if ((x != k) && (y != k))
                    {
                        if (x > y) { o[y] += (v[x] * -sin(r)); }
                        else if (y > x) { o[y] += (v[x] * sin(r)); }
                    }
                }
            }
            v = o;
            o = z;
        }

        void RotateN(inout float v[N], uint n, float r)
        {
            uint k = 0;
            for (k = 1; k < n; ++k)
            {
                float a = -AtanN(k + 1);
                RotateA(v, n, a, k);
            }
            RotateA(v, n, r, 0);
            for (k = 1; k < n; ++k)
            {
                float a = AtanN(n - k + 1);
                RotateA(v, n, a, n - k);
            }
        }

        void RotateHue(inout float v[N], uint n, float r)
        {
            RotateN(v, n, r);
        }

        void TranslateRadiance(inout float v[N], uint n, float t)
        {
            for (uint i = 0; i < n; ++i)
            {
                if (i == 0) { v[i] += t; }
                else { v[i] -= t; }
            }
        }

        void ScaleValue(inout float v[N], uint n, float s)
        {
            for (uint i = 0; i < n; ++i)
            {
                v[i] *= s;
            }
        }

        void vertex(inout appdata_full v, out Input o)
        {
            float data[3];
            data[0] = v.vertex.x;
            data[1] = v.vertex.y;
            data[2] = v.vertex.z;
            RotateHue(data, 3, _DebugHue);
            TranslateRadiance(data, 3, _DebugRadiance);
            ScaleValue(data, 3, _DebugValue);
            v.vertex.x = data[0];
            v.vertex.y = data[1];
            v.vertex.z = data[2];
            o = (Input)0;
            o.vertex = v.vertex.xyz;
        }

        void surface(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            c = c * 0.5 + tex2D(_Texture, (IN.uv_MainTex * _Texture_ST.xy) + _Texture_ST.zw) * 0.5;
            c = c * 0.5 + _Color * 0.5;
            c = fixed4(IN.vertex, 0.5);
            float data[3];
            data[0] = c.r;
            data[1] = c.g;
            data[2] = c.b;
            RotateN(data, 3, -_DebugHue);
            c.r = data[0];
            c.g = data[1];
            c.b = data[2];
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
