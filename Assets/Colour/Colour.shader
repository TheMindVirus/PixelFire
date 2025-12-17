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
        _DebugSaturation ("Saturation", Float) = 0.0
        _DebugValue ("Value", Float) = 1.0
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
        float _DebugHue;
        float _DebugSaturation;
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

        void RotateXYZ(inout float3 v, float r)
        {
            float4 o = float4(0.0, 0.0, 0.0, 0.0);

            float pi = 3.1415926;
            float d = pi / 180.0;
            float a = 35.0 * d;
            float b = -45.0 * d;

            o.x = (v.x * cos(-b)) + (v.y * -sin(-b));
            o.y = (v.x * sin(-b)) + (v.y * cos(-b));
            o.z = v.z;

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);

            o.x = v.x;
            o.y = (v.y * cos(-a)) + (v.z * -sin(-a));
            o.z = (v.y * sin(-a)) + (v.z * cos(-a));

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);

            o.x = (v.x * cos(r)) + (v.z * -sin(r));
            o.y = v.y;
            o.z = (v.x * sin(r)) + (v.z * cos(r));

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);

            o.x = v.x;
            o.y = (v.y * cos(a)) + (v.z * -sin(a));
            o.z = (v.y * sin(a)) + (v.z * cos(a));

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);

            o.x = (v.x * cos(b)) + (v.y * -sin(b));
            o.y = (v.x * sin(b)) + (v.y * cos(b));
            o.z = v.z;

            v = o;
            o = float4(0.0, 0.0, 0.0, 0.0);
        }

        void RotateHue(inout float3 v, float r)
        {
            RotateXYZ(v, r);
        }

        void TranslateSaturation(inout float3 v, float t)
        {
            v += t;
        }

        void ScaleValue(inout float3 v, float s)
        {
            v *= s;
        }

        void vertex(inout appdata_full v, out Input o)
        {
            RotateHue(v.vertex.xyz, _DebugHue);
            TranslateSaturation(v.vertex.xyz, _DebugSaturation);
            ScaleValue(v.vertex.xyz, _DebugValue);
            o = (Input)0;
            o.vertex = v.vertex.xyz;
        }

        void surface(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            c = c * 0.5 + tex2D(_Texture, (IN.uv_MainTex * _Texture_ST.xy) + _Texture_ST.zw) * 0.5;
            c = c * 0.5 + _Color * 0.5;
            c = fixed4(IN.vertex, 0.5);
            RotateXYZ(c.rgb, -_DebugHue);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
