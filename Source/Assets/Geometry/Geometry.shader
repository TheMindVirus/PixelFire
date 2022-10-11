Shader "Custom/Geometry"
{
    Properties
    {
        _Color("Colour", Color) = (1,1,1,1)
        _MainTex("Texture", 2D) = "white" {}
        _AlphaTex("Alpha", 2D) = "white" {}
        _Width("Grass Width", Range(0.0, 0.1)) = 0.05
        _Height("Grass Height", Float) = 3.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vertex
            #pragma geometry geometry
            #pragma fragment fragment
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            half4 _Color;
            sampler2D _MainTex;
            sampler2D _AlphaTex;
            half _Width;
            half _Height;

            struct v2g
            {
                half4 pos : SV_POSITION;
                half3 norm : NORMAL;
                half2 uv : TEXCOORD0;
            };

            struct g2f
            {
                half4 pos : SV_POSITION;
                half3 norm : NORMAL;
                half2 uv : TEXCOORD0;
            };

            static const half oscillateDelta = 0.05;

            g2f createGSOut()
            {
                g2f output;
                output.pos = half4(0, 0, 0, 0);
                output.norm = half3(0, 0, 0);
                output.uv = half2(0, 0);
                return output;
            }

            v2g vertex(appdata_full v)
            {
                v2g o;
                o.pos = v.vertex;
                o.norm = v.normal;
                o.uv = v.texcoord;
                return o;
            }

            //[maxvertexcount(4)]
            //[maxvertexcount(30)]
            [maxvertexcount(101)]
            void geometry(point v2g points[1], inout TriangleStream<g2f> triStream)
            {
                half4 root = points[0].pos;
                const int vertexCount = 12;
                half random = sin(UNITY_HALF_PI * frac(root.x) + UNITY_HALF_PI * frac(root.z));

                _Width = _Width + (random / 50);
                _Height = _Height + (random / 5);

                g2f v[vertexCount] =
                {
                    createGSOut(), createGSOut(), createGSOut(), createGSOut(),
                    createGSOut(), createGSOut(), createGSOut(), createGSOut(),
                    createGSOut(), createGSOut(), createGSOut(), createGSOut()
                };

                half currentV = 0;
                half offsetV = 1.0f / ((vertexCount / 2) - 1);
                half currentHeightOffset = 0;
                half currentVertexHeight = 0;
                half windCoEff = 0;

                for (int i = 0; i < vertexCount; ++i)
                {
                    v[i].norm = half3(0, 0, 1);
                    if (fmod(i , 2) == 0)
                    { 
                        v[i].pos = half4(root.x - _Width , root.y + currentVertexHeight, root.z, 1);
                        v[i].uv = half2(0, currentV);
                    }
                    else
                    { 
                        v[i].pos = half4(root.x + _Width , root.y + currentVertexHeight, root.z, 1);
                        v[i].uv = half2(1, currentV);
                        currentV += offsetV;
                        currentVertexHeight = currentV * _Height;
                    }
                    half2 wind = half2(sin(_Time.x * UNITY_PI * 5), sin(_Time.x * UNITY_PI * 5));
                    wind.x += (sin(_Time.x + root.x / 25) + sin((_Time.x + root.x / 15) + 50)) * 0.5f;
                    wind.y += cos(_Time.x + root.z / 80);
                    wind *= lerp(0.7f, 1.0f, 1.0f - random);

                    half oscillationStrength = 2.5f;
                    half sinSkewCoeff = random;
                    half lerpCoeff = (sin(oscillationStrength * _Time.x + sinSkewCoeff) + 1.0f) / 2;
                    half2 leftWindBound = wind * (1.0f - oscillateDelta);
                    half2 rightWindBound = wind * (1.0f + oscillateDelta);
                    wind = lerp(leftWindBound, rightWindBound, lerpCoeff);
                    half randomAngle = lerp(-UNITY_PI, UNITY_PI, random);
                    half randomMagnitude = lerp(0, 1.0f, random);
                    half2 randomWindDir = half2(sin(randomAngle), cos(randomAngle));
                    wind += randomWindDir * randomMagnitude;
                    half windForce = length(wind);
                    v[i].pos.xz += wind.xy * windCoEff;
                    v[i].pos.y -= windForce * windCoEff * 0.8f;
                    v[i].pos = UnityObjectToClipPos(v[i].pos);
                    if (fmod(i, 2) == 1) { windCoEff += offsetV; }
                }

                for (int p = 0; p < (vertexCount - 2); ++p)
                {
                    triStream.Append(v[p]);
                    g2f v2 = v[p];
                    v2.pos += half4(0.001f, 0.001f, 0.001f, 0.0f);
                    triStream.Append(v2);
                    g2f v3 = v[p];
                    v3.pos -= half4(0.001f, 0.001f, 0.001f, 0.0f);
                    triStream.Append(v3);
                    //triStream.Append(v[p + 2]);
                    //triStream.Append(v[p + 1]);
                    if (p == 2) { break; }
                }
            }

            half4 fragment(g2f IN) : COLOR
            {
                half4 color = tex2D(_MainTex, IN.uv);
                half4 alpha = tex2D(_AlphaTex, IN.uv);
                half3 worldNormal = UnityObjectToWorldNormal(IN.norm);
                half3 light;
                half3 ambient = ShadeSH9(half4(worldNormal, 1));
                half3 diffuseLight = saturate(dot(worldNormal, UnityWorldSpaceLightDir(IN.pos))) * _LightColor0;
                half3 halfVector = normalize(UnityWorldSpaceLightDir(IN.pos) + WorldSpaceViewDir(IN.pos));
                half3 specularLight = pow(saturate(dot(worldNormal, halfVector)), 15) * _LightColor0;
                light = ambient + diffuseLight + specularLight;
                half4 output = half4(color.rgb * light, alpha.g);
                output.rgb = _LightColor0.rgb;
                output.a = 0.5f;
                return output;
            }
            ENDCG
        }
    }
}