Shader "Custom/Attenuation"
{
    SubShader
    {
        Tags { "RenderType" = "Opaque" } //DO NOT CHANGE THE RENDER QUEUE
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_fwdbase nolightmap nodynlightmap novertexlight
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct vertex_data
            {
                float4 screen : SV_POSITION;
                float4 _ShadowCoord : TEXCOORD2;
            };

            vertex_data vertex_shader(appdata_full input)
            {
                vertex_data output;
                output.screen = UnityObjectToClipPos(input.vertex);
                output._ShadowCoord = ComputeScreenPos(output.screen); //DO NOT RENAME _ShadowCoord TO shadow
                return output;
            }

            float4 fragment_shader(vertex_data input) : SV_Target
            {
                UNITY_LIGHT_ATTENUATION(attenuation, input, 0)
                float4 output = attenuation; //!!!WHAT!!!
                output.rgb *= _LightColor0.rgb;
                output.a = 0.5f;
                return output;
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_fwdadd_fullshadows
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct vertex_data
            {
                float4 screen : SV_POSITION;
                float3 world : TEXCOORD0;
                float3 _ShadowCoord : TEXCOORD2; //DO NOT RENAME _ShadowCoord TO shadow
            };

            vertex_data vertex_shader(appdata_full input)
            {
                vertex_data output;
                output.screen = UnityObjectToClipPos(input.vertex);
                output.world = mul(unity_ObjectToWorld, input.vertex).xyz;
                output._ShadowCoord = ComputeScreenPos(output.screen);
                return output;
            }

            float4 fragment_shader(vertex_data input) : SV_Target
            {
                UNITY_LIGHT_ATTENUATION(attenuation, input, input.world)
                float4 output;
                output.rgb = _LightColor0.rgb * attenuation * UnityObjectToWorldNormal(input.screen);
                output.a = (output.r + output.g + output.b); // 3.0f;
                return output;
            }
            ENDCG
        }
        Pass //DO NOT REMOVE ANYTHING FROM HERE
        {
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            void vertex_shader() {}
            void fragment_shader() {}
            ENDCG
        }
    }
}