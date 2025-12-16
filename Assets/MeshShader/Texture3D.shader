Shader "Custom/Texture3D"
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
            Tags { "LightMode" = "Always" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front ZWrite Off ZTest LEqual //NotEqual

            HLSLPROGRAM
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #include "UnityCG.cginc"

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
