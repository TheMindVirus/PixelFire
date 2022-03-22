Shader "Custom/LitVolume"
{
    Properties
    {
        _Color("Colour", Color) = (1.0, 1.0, 1.0, 0.1)
        _Texture("Texture", 3D) = "" {}
        _Steps("Steps", Range(1, 100)) = 100
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" } //DO NOT CHANGE THE RENDER QUEUE
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZWrite Off
            ZTest LEqual //NotEqual

            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_fwdbase nolightmap nodynlightmap novertexlight
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler3D _Texture;
            float4 _Color;
            uint _Steps;

            struct appdata
            {
                float4 vertex       : TEXCOORD0; //DO NOT USE float3 OR POSITION
                float3 world        : TEXCOORD1;
                float4 _ShadowCoord : TEXCOORD2; //DO NOT RENAME _ShadowCoord TO shadow
                float4 screen       : POSITION;
            };

            appdata vertex_shader(appdata_full input)
            {
                appdata output;
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(output.vertex);
                output.world = mul(unity_ObjectToWorld, output.vertex).xyz;
                output._ShadowCoord = ComputeScreenPos(output.screen);
                return output;
            }

            float4 fragment_shader(appdata input) : COLOR
            {
                float4 output = float4(0.0f, 0.0f, 0.0f, 0.0f);
                int tmp = _Steps; if (tmp < 0) { tmp = 0; }
                uint steps = tmp;
                const float stride = 2.0f / steps;
                
                float3 origin = input.vertex.xyz + float3(0.5f, 0.5f, 0.5f);
                float3 direction = normalize(ObjSpaceViewDir(float4(input.vertex.xyz, 0.0f)));

                origin += direction * stride;

                [unroll(99)]
                for (uint i = 0; i < steps; ++i)
                {
                    float3 position = origin + direction * (i * stride);
                    if (position.x < 0.0f
                    ||  position.x > 1.0f
                    ||  position.y < 0.0f
                    ||  position.y > 1.0f
                    ||  position.z < 0.0f
                    ||  position.z > 1.0f) { break; }

                    appdata v;
                    v.vertex = float4(position - origin, 0.0f);
                    v.screen = UnityObjectToClipPos(v.vertex);
                    v.world = input.world + v.vertex.xyz;
                    v._ShadowCoord = ComputeScreenPos(v.screen);

                    float4 source = tex3Dlod(_Texture, float4(position.x, position.y, position.z, 0.0f));
                    UNITY_LIGHT_ATTENUATION(attenuation, v, v.world);
                    float4 augment = attenuation; //!!!WHAT!!!
                    augment.rgb *= _LightColor0.rgb;
                    augment.a = (augment.r + augment.g + augment.b); // / 3.0f;
                    source.rgb *= _Color.rgb;
                    source.rgb = (source.rgb + augment.rgb) * 0.5f;
                    source.a = (source.a + augment.a) * 0.5f;
                    source.a *= _Color.a;

                    output.rgb = (source.rgb * source.a) + ((1.0f - source.a) * output.rgb);
                    output.a = (source.a * 0.5f) + ((1.0f - source.a) * output.a);
                }
                return output;
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front //Back
            ZWrite Off
            ZTest LEqual //NotEqual

            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_fwdadd_fullshadows
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler3D _Texture;
            float4 _Color;
            uint _Steps;

            struct appdata
            {
                float4 vertex       : TEXCOORD0; //DO NOT USE float3 OR POSITION
                float3 world        : TEXCOORD1;
                float4 _ShadowCoord : TEXCOORD2; //DO NOT RENAME _ShadowCoord TO shadow
                float4 screen       : POSITION;
            };

            appdata vertex_shader(appdata_full input)
            {
                appdata output;
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(output.vertex);
                output.world = mul(unity_ObjectToWorld, output.vertex).xyz;
                output._ShadowCoord = ComputeScreenPos(output.screen);
                return output;
            }

            float4 fragment_shader(appdata input) : COLOR
            {
                float4 output = float4(0.0f, 0.0f, 0.0f, 0.0f);
                int tmp = _Steps; if (tmp < 0) { tmp = 0; }
                uint steps = tmp;
                const float stride = 2.0f / steps;
                
                float3 origin = input.vertex.xyz + float3(0.5f, 0.5f, 0.5f);
                float3 direction = normalize(ObjSpaceViewDir(float4(input.vertex.xyz, 0.0f)));

                origin += direction * stride;

                [unroll(99)]
                for (uint i = 0; i < steps; ++i)
                {
                    float3 position = origin + direction * (i * stride);
                    if (position.x < 0.0f
                    ||  position.x > 1.0f
                    ||  position.y < 0.0f
                    ||  position.y > 1.0f
                    ||  position.z < 0.0f
                    ||  position.z > 1.0f) { break; }

                    appdata v;
                    v.vertex = float4(position - origin, 0.0f);
                    v.screen = UnityObjectToClipPos(v.vertex);
                    v.world = input.world + v.vertex.xyz;
                    v._ShadowCoord = ComputeScreenPos(v.screen);

                    //float4 source = tex3Dlod(_Texture, float4(position.x, position.y, position.z, 0.0f));
                    float4 source = float4(0,0,0,0);
                    UNITY_LIGHT_ATTENUATION(attenuation, v, v.world);
                    float4 augment = attenuation; //!!!WHAT!!!
                    augment.rgb *= _LightColor0.rgb;
                    augment.a = (augment.r + augment.g + augment.b); // / 3.0f;
                    source.rgb *= _Color.rgb;
                    source.rgb = (source.rgb + augment.rgb) * 0.5f;
                    source.a = (source.a + augment.a) * 0.5f;
                    source.a *= _Color.a;

                    output.rgb = (source.rgb * source.a) + ((1.0f - source.a) * output.rgb);
                    output.a = (source.a * 0.5f) + ((1.0f - source.a) * output.a);
                }
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