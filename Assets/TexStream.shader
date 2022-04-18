Shader "Custom/TexStream"
{
    Properties
    {
        _MainTex ("Texture", 3D) = "white" {}
        _Color ("Colour", Color) = (1.0, 1.0, 1.0, 1.0)
        _Alpha ("Alpha", float) = 0.02
        _StepSize ("Step Size", float) = 0.01
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #define RAYTRACE_SAMPLES   128
            #define EPSILON            0.00001f

            sampler3D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Alpha;
            float _StepSize;

            struct vertex_data
            {
                float4 vertex : POSITION;
            };

            struct fragment_data
            {
                float4 vertex : SV_POSITION;
                float3 object : TEXCOORD0;
                float3 surface : TEXCOORD1;
                float3 world : WORLD_POSITION;
                float4 light : INCIDENT_LIGHT;
            };

            float4 BlendUnder(float4 input, float4 value) //Blackmagic
            {
                float4 output = input;
                output.rgb += (1.0f - input.a) * value.a * value.rgb;
                output.a += (1.0f - input.a) * value.a;
                return output;
            }

            fragment_data vertex_shader(vertex_data input)
            {
                fragment_data output;
                output.object = input.vertex;
                output.world = mul(unity_ObjectToWorld, input.vertex).xyz;
                output.surface = output.world - _WorldSpaceCameraPos;
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.light = _Color * _LightColor0;
                return output;
            }

            fixed4 fragment_shader(fragment_data input) : COLOR
            {
                float4 output = float4(0.0f, 0.0f, 0.0f, 0.0f);
                float3 origin = input.object;
                float3 direction = mul(unity_WorldToObject, float4(normalize(input.surface), 1.0f));
                float3 position = origin;

                for (int i = 0; i < RAYTRACE_SAMPLES; ++i)
                {
                    if (max(abs(position.x), max(abs(position.y), abs(position.z))) < 0.5f + EPSILON)
                    {
                        float4 sampled = tex3D(_MainTex, position + float3(0.5f, 0.5f, 0.5f));
                        sampled.a *= _Alpha;
                        output = BlendUnder(output, sampled);
                        output.rgb *= input.light.rgb * _Color.rgb;
                        output.a *= _Color.a;
                        position += direction * _StepSize;
                    }
                }
                return output;
            }
            ENDCG
        }
    }
}