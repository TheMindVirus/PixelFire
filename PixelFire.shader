Shader "Lit/PixelFire"
{
    Properties
    {
        _Texture ("Texture", 3D) = "" {}
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front ZWrite Off ZTest LEqual //NotEqual

        Pass
        {
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front ZWrite Off ZTest LEqual //NotEqual

            HLSLPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_fwdbase nolightmap nodynlightmap novertexlight
            //#include "UnityCG.cginc"
            //#include "Lighting.cginc"
            //#include "AutoLight.cginc"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            sampler3D _Texture;

            struct appdata_input
            {
                half4 vertex : POSITION;
            };

            struct appdata
            {
                half4 vertex : TEXCOORD0;
                half4 world : TEXCOORD1;
                half4 screen : POSITION;
            };

            appdata vertex_shader(appdata_input input)
            {
                appdata output;
                output.vertex = input.vertex;
                //output.screen = UnityObjectToClipPos(output.vertex);
                output.world = mul(unity_ObjectToWorld, output.vertex);
                output.screen = mul(UNITY_MATRIX_VP, output.world);
                return output;
            }

            half4 fragment_shader(appdata input) : COLOR
            {
                half4 output = half4(0.0f, 0.0f, 0.0f, 0.0f);
                const half stride = 2.0f / 100;

                half3 origin = input.vertex.xyz + half3(0.5f, 0.5f, 0.5f);
                //half3 direction = normalize(ObjSpaceViewDir(half4(input.vertex.xyz, 0.0f)));

                half3 direction = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos.xyz, 1)).xyz;
                direction -= input.vertex.xyz;
                direction = normalize(direction);

                origin += direction * stride;

                uint flag = 1;
                for (uint i = 0; i < 100; ++i)
                {
                    half3 position = origin + direction * (i * stride);
                    if (position.x < 0.0f
                    ||  position.x > 1.0f
                    ||  position.y < 0.0f
                    ||  position.y > 1.0f
                    ||  position.z < 0.0f
                    ||  position.z > 1.0f) { flag = 0; }

                    if (flag == 1)
                    {
                        appdata v;
                        v.vertex = half4(position - origin, 0.0f);
                        v.world = input.world + half4(v.vertex.xyz, 0.0f);
                        v.screen = mul(UNITY_MATRIX_VP, v.world);

                        half4 source = half4(0,0,0,0);
                        half4 augment = tex3Dlod(_Texture, half4(position.xyz, 0));

                        uint lights = GetAdditionalLightsCount();
                        half3 light = half3(0.0, 0.0, 0.0);
                        for (uint j = 0; j < lights; ++j)
                        {
                            Light pod = GetAdditionalLight(j, v.world);
                            half atten = LightingLambert(pod.color, pod.direction, 1.0);
                            half3 pods = pod.color * atten;
                            light = (light * 0.5) + (pods * 0.5);
                        }
                        augment.rgb *= light;
                        source.rgb = (source.rgb + augment.rgb) * 0.5f;
                        source.a = (source.a + augment.a) * 0.5f;

                        output.rgb = (source.rgb * source.a) + ((1.0f - source.a) * output.rgb);
                        output.a = (source.a * 0.5f) + ((1.0f - source.a) * output.a);
                    }
                }
                return output;
            }
            ENDHLSL
        }
    }
}
