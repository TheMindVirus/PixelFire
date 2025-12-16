Shader "Custom/4D"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Texture ("Texture", 2D) = "" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _DebugRotation ("Rotation", Vector) = (0.0, 0.0, 0.0)
        _DebugMorph ("Morph", Vector) = (0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }

        CGPROGRAM
        #pragma surface surface Standard vertex:vertex alpha:blend fullforwardshadows
        #pragma target 3.0

        fixed4 _Color;
        sampler2D _MainTex;
        //float4 _MainTex_ST;
        sampler2D _Texture;
        float4 _Texture_ST;
        half _Glossiness;
        half _Metallic;
        float3 _DebugRotation;
        float3 _DebugMorph;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
            float4 color : COLOR;
            float4 screenPos;
            float3 worldPos;
            float3 worldRefl;
            float3 worldNormal;
        };

        void Rotate4D(inout float4 v, float3 r, float3 m)
        {
            float4 o = float4(0.0, 0.0, 0.0, 0.0);

            o.x = v.x;
            o.y = (v.y * cos(r.x)) + (v.z * -sin(r.x));
            o.z = (v.y * sin(r.x)) + (v.z * cos(r.x));
            o.w = v.w;

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);

            o.x = (v.x * cos(r.y)) + (v.z * -sin(r.y));
            o.y = v.y;
            o.z = (v.x * sin(r.y)) + (v.z * cos(r.y));
            o.w = v.w;

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);

            o.x = (v.x * cos(r.z)) + (v.y * -sin(r.z));
            o.y = (v.x * sin(r.z)) + (v.y * cos(r.z));
            o.z = v.z;
            o.w = v.w;

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);

            o.x = (v.x * cos(m.x)) + (v.w * -sin(m.x));
            o.y = v.y;
            o.z = v.z;
            o.w = (v.x * sin(m.x)) + (v.w * cos(m.x));

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);

            o.x = v.x;
            o.y = (v.y * cos(m.y)) + (v.w * -sin(m.y));
            o.z = v.z;
            o.w = (v.y * sin(m.y)) + (v.w * cos(m.y));

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);

            o.x = v.x;
            o.y = v.y;
            o.z = (v.z * cos(m.z)) + (v.w * -sin(m.z));
            o.w = (v.z * sin(m.z)) + (v.w * cos(m.z));

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);
        }

        void vertex(inout appdata_full v)
        {
            Rotate4D(v.vertex.xyzw, _DebugRotation, _DebugMorph);
            v.vertex.xyz *= v.vertex.w;
        }

        void surface(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            c = c * 0.5 + tex2D(_Texture, (IN.uv_MainTex * _Texture_ST.xy) + _Texture_ST.zw) * 0.5;
            c = c * 0.5 + _Color * 0.5;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
