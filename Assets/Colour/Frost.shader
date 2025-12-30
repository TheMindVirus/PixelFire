Shader "Custom/Frost"
{
    Properties
    {
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "" {}
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.5
        _Opacity ("Opacity", Range(0, 1)) = 1.0
        _Frost ("Frost", Range(0, 1)) = 0.0
        _Warp ("Warp", Range(0, 1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "Queue" = "Geometry" }
        GrabPass { "_GrabPass" }

        CGPROGRAM
        #pragma surface surface Frost vertex:vertex alpha:blend fullforwardshadows
        #define PI 3.141526

        fixed4 _Color;
        sampler2D _MainTex;
        sampler2D _GrabPass;
        half _Glossiness;
        half _Metallic;
        half _Opacity;
        half _Frost;
        half _Warp;

        struct Input
        {
            float4 screenPos : SV_POSITION;
            float2 uv_MainTex : TEXCOORD0;
            float4 GrabUV : TEXCOORD1;
            float4 worldPos;
            float3 worldNormal;
            float3 viewDir;
            float3 worldRefl;
        };

        half Sharpen(half v, half n)
        {
            half c = (v / 2.0) + 0.5;
            if (c == 0.0) { return -1.0; }
            return -log((1 / c) - 1) / log(n);
        }

        half Soften(half v, half n)
        {
            return ((1.0 / (1.0 + pow(n, -v))) - 0.5) * 2.0;
        }

        half4 LightingFrost(SurfaceOutput s, half3 dir, half atten)
        {
            half ndotl = dot(s.Normal, dir);
            half4 c = half4(0.0, 0.0, 0.0, 0.0);
            half ndotla = ndotl * atten;
            //ndotla *= (1.0 - _Metallic);
            if (_Metallic > 0.5) { ndotla = Sharpen(ndotla, (_Metallic - 0.5)); }
            if (_Metallic < 0.5) { ndotla = Soften(ndotla, 1.0 - (_Metallic - 0.5)); }
            c.rgb = s.Albedo * _LightColor0.rgb * (ndotla);
            c.a = s.Alpha;
            return c;
        }

        void vertex(inout appdata_full v, out Input o)
        {
            o.screenPos = UnityObjectToClipPos(v.vertex);
            o.uv_MainTex = v.texcoord;
            o.GrabUV = ComputeGrabScreenPos(o.screenPos);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex);
            o.worldNormal = UnityObjectToWorldNormal(v.normal);
            o.viewDir = WorldSpaceViewDir(o.worldPos);
            o.worldRefl = reflect(-o.viewDir, o.worldNormal);
        }

        void surface(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            //fixed3 normal = IN.worldRefl + ((_Warp / 10.0) * sin(IN.uv_MainTex.y) * 100.0);
            fixed3 normal = reflect(-IN.viewDir, IN.worldNormal) + ((_Warp / 10.0) * sin(IN.uv_MainTex.y) * 100.0);
            c.rgb = (c.rgb * 0.5) + (UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, normal) * _Glossiness);

            fixed4 proj = UNITY_PROJ_COORD(IN.GrabUV);
            proj.x += (_Frost / 10.0) * atan(sin(IN.uv_MainTex.x) * cos(IN.uv_MainTex.y) * 512.0);
            proj.y += (_Frost / 10.0) * atan(sin(IN.uv_MainTex.x) * cos(IN.uv_MainTex.y) * 512.0);
            fixed4 lvl = tex2Dproj(_GrabPass, proj);
            c.rgb = (c.rgb * 0.5) + (lvl.rgb * (1.0 - _Opacity));

            o.Albedo = c.rgb;
            o.Alpha = c.a;
            //o.Metallic = _Metallic;
            //o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
