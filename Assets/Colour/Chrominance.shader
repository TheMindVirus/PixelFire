Shader "Custom/Chrominance"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Chrominance ("Chrominance (YUV)", Vector) = (1.0, 1.0, 1.0, 1.0)
        _Constance ("Constance (K)", Vector) = (0.299, 0.587, 0.114, 0.333333)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Transparent" }

        CGPROGRAM
        #pragma surface surface Standard fullforwardshadows alpha:blend
        #pragma target 3.0

        fixed4 _Color;
        sampler2D _MainTex;
        half _Glossiness;
        half _Metallic;
        fixed4 _Chrominance;
        fixed4 _Constance;

        struct Input
        {
            float2 uv_MainTex;
        };

        void RGB2YUV(inout float3 c, float3 k)
        {
            float3 o = float3(0.0, 0.0, 0.0);
            o.r = (c.r * k.r) + (c.g * k.g) + (c.b * k.b);
            o.g = (c.r * (-0.5 * (k.r / (1.0 - k.b)))) + (c.g * (-0.5 * (k.g / (1.0 - k.b)))) + (c.b * 0.5);
            o.b = (c.r * 0.5) + (c.g * (-0.5 * (k.g / (1.0 - k.r)))) + (c.b * (-0.5 * (k.b / (1.0 - k.r))));
            c = o;
        }

        void YUV2RGB(inout float3 c, float3 k)
        {
            float3 o = float3(0.0, 0.0, 0.0);
            o.r = c.r + (c.b * (2.0 - (2.0 * k.r)));
            o.g = c.r + (c.g * (-(k.b / k.g) * (2.0 - (2.0 * k.b)))) + (c.b * (-(k.r / k.g) * (2.0 - (2.0 * k.r))));
            o.b = c.r + (c.g * (2.0 - (2.0 * k.b)));
            c = o;
        }

        void surface(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            RGB2YUV(c.rgb, _Constance.rgb);
            c.rgb *= _Chrominance.rgb;
            YUV2RGB(c.rgb, _Constance.rgb);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
