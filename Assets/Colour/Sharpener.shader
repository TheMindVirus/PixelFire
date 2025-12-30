Shader "Custom/Sharpener"
{
    Properties
    {
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        CGPROGRAM
        #pragma surface surface Sharpener alpha:blend fullforwardshadows
        #define PI 3.141526

        fixed4 _Color;
        sampler2D _MainTex;
        half _Glossiness;
        half _Metallic;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldRefl;
        };

        half Sharpen(half v)
        {
            return asin(v) / (0.5 * PI);
        }

        half Soften(half v)
        {
            return sin(v * 0.5 * PI);
        }

        half4 LightingSharpener(SurfaceOutput s, half3 dir, half atten)
        {
            half ndotl = dot(s.Normal, dir);
            half4 c = half4(0.0, 0.0, 0.0, 0.0);
            half ndotla = ndotl * atten;
            //half refl = reflect(dir, s.Normal);

            int iterations = (int)(((_Metallic * 2.0) - 1.0) * 10.0);
            uint steps = abs(iterations);
            uint flags = (iterations >= 0) ? 1 : 0;
            for (uint i = 0; i < steps; ++i)
            {
                if (flags == 1) { ndotla = Sharpen(ndotla); }
                else { ndotla = Soften(ndotla); }
            }

            c.rgb = s.Albedo * _LightColor0.rgb * (ndotla);
            //c.rgb = (c.rgb * (1.0 - _Glossiness)) + (UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, refl) * _Glossiness);
            c.a = s.Alpha;
            return c;
        }

        void surface(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            //c = fixed4(Soften(IN.uv_MainTex.x), Soften(IN.uv_MainTex.y), 0.0, 1.0);
            c.rgb = (c.rgb * (1.0 - _Glossiness)) + (UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, IN.worldRefl) * _Glossiness);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            //o.Metallic = _Metallic;
            //o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
