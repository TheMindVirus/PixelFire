Shader "Custom/LitVolume" //Patched because lighting engine uses oddly scaled/unscaled world position
{
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front ZWrite Off ZTest LEqual //NotEqual

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front ZWrite Off ZTest LEqual //NotEqual

            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_fwdbase nolightmap nodynlightmap novertexlight
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                fixed4 vertex       : TEXCOORD0; //DO NOT USE fixed3 OR POSITION
                fixed3 world        : TEXCOORD1;
                fixed4 _ShadowCoord : TEXCOORD2; //DO NOT RENAME _ShadowCoord TO shadow
                fixed4 screen       : POSITION;
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

            fixed4 fragment_shader(appdata input) : COLOR
            {
                fixed4 output = fixed4(0.0f, 0.0f, 0.0f, 0.0f);
                const fixed stride = 2.0f / 100;
                
                fixed3 origin = input.vertex.xyz + fixed3(0.5f, 0.5f, 0.5f);
                fixed3 direction = normalize(ObjSpaceViewDir(fixed4(input.vertex.xyz, 0.0f)));

                origin += direction * stride;

                uint flag = 1;
                for (uint i = 0; i < 100; ++i)
                {
                    fixed3 position = origin + direction * (i * stride);
                    if (position.x < 0.0f
                    ||  position.x > 1.0f
                    ||  position.y < 0.0f
                    ||  position.y > 1.0f
                    ||  position.z < 0.0f
                    ||  position.z > 1.0f) { flag = 0; }

                    if (flag == 1)
                    {
                        appdata v;
                        v.vertex = fixed4(position - origin, 0.0f);
                        v.screen = UnityObjectToClipPos(v.vertex);
                        v.world = input.world + v.vertex.xyz;
                        v._ShadowCoord = ComputeScreenPos(v.screen);

                        fixed4 source = fixed4(0,0,0,0);
                        UNITY_LIGHT_ATTENUATION(attenuation, v, v.world);
                        fixed4 augment = attenuation; //!!!WHAT!!!
                        augment.rgb *= _LightColor0.rgb;
                        augment.a = (augment.r + augment.g + augment.b); // / 3.0f;
                        source.rgb = (source.rgb + augment.rgb) * 0.5f;
                        source.a = (source.a + augment.a) * 0.5f;

                        output.rgb = (source.rgb * source.a) + ((1.0f - source.a) * output.rgb);
                        output.a = (source.a * 0.5f) + ((1.0f - source.a) * output.a);
                    }
                }
                return output;
            }
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardAdd" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front ZWrite Off ZTest LEqual //NotEqual

            CGPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_fwdadd_fullshadows
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                fixed4 vertex       : TEXCOORD0;
                fixed4 world        : TEXCOORD1;
                fixed4 _ShadowCoord : TEXCOORD2;
                fixed4 screen       : POSITION;
            };

            appdata vertex_shader(appdata_full input)
            {
                appdata output;
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(output.vertex);
                output.world = mul(unity_ObjectToWorld, output.vertex);
                output._ShadowCoord = ComputeScreenPos(output.screen);
                return output;
            }

            fixed4 fragment_shader(appdata input) : COLOR
            {
                fixed4 output = fixed4(0.0f, 0.0f, 0.0f, 0.0f);
                const fixed stride = 2.0f / 100;
                
                fixed3 origin = input.vertex.xyz + fixed3(0.5f, 0.5f, 0.5f);
                fixed3 direction = normalize(ObjSpaceViewDir(fixed4(input.vertex.xyz, 0.0f)));

                origin += direction * stride;

                uint flag = 1;
                for (uint i = 0; i < 100; ++i)
                {
                    fixed3 position = origin + direction * (i * stride);
                    if (position.x < 0.0f
                    ||  position.x > 1.0f
                    ||  position.y < 0.0f
                    ||  position.y > 1.0f
                    ||  position.z < 0.0f
                    ||  position.z > 1.0f) { flag = 0; }

                    if (flag == 1)
                    {
                        appdata v;
                        v.vertex = fixed4(position - origin, 0.0f);
                        v.screen = UnityObjectToClipPos(v.vertex);
                        //v.world = input.world + v.vertex.xyz; //Patched because 3DTexCoord is locally vertex scaled
                        v.world = input.world + mul(unity_ObjectToWorld, v.vertex.xyz); //but LightAttenuation is world scaled
                        v._ShadowCoord = ComputeScreenPos(v.screen); //And ShadowCoord is screen scaled

                        fixed4 source = fixed4(0,0,0,0);
                        UNITY_LIGHT_ATTENUATION(attenuation, v, v.world.xyz);
                        fixed4 augment = attenuation; //!!!WHAT!!!
                        augment.rgb *= _LightColor0.rgb * 0.1f; //Needs Clamping
                        augment.a = (augment.r + augment.g + augment.b); // / 3.0f;
                        source.rgb = (source.rgb + augment.rgb) * 0.5f;
                        source.a = (source.a + augment.a) * 0.5f;

                        output.rgb = (source.rgb * source.a) + ((1.0f - source.a) * output.rgb);
                        output.a = (source.a * 0.5f) + ((1.0f - source.a) * output.a);
                    }
                }
                return output;
            }
            ENDCG
        }
        Pass
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