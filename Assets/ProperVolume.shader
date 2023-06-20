Shader "VolumeRendering/ProperVolumeShader"
{
    Properties
    {
        _Texture("Texture", 3D) = "" {}
        _Steps("Steps", Float) = 512
        _Frame("Frame", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "LightMode" = "Always" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front
        ZWrite Off
        ZTest LEqual //NotEqual

        Pass
        {
            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            sampler3D _Texture;
            uint _Steps;
            uint _Frame;

            struct appdata
            {
                float3 vertex : TEXCOORD1;
                float4 screen : SV_POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            appdata vertex_shader(appdata_full input)
            {
                appdata output;
                output.vertex = input.vertex;
                output.screen = UnityObjectToClipPos(input.vertex);
                output.normal = UnityObjectToWorldNormal(input.normal);
                output.texcoord = input.texcoord;
                return output;
            }

            float4 fragment_shader(appdata input) : SV_TARGET
            {
                float4 output;
                float4 previous;
                int tmp = _Steps; if (tmp < 0) { tmp = 0; }
                uint steps = tmp;
                const float stride = 2.0f / steps;
                
                float3 origin = input.vertex + float3(0.5f, 0.5f, 0.5f);
                float3 direction = normalize(ObjSpaceViewDir(float4(input.vertex, 0.0f)));

                origin += direction * stride;

                for (uint i = 0; i < steps; ++i)
                {
                    float3 position = origin + direction * (i * stride);
                    if (position.x < 0.0f
                    ||  position.x > 1.0f
                    ||  position.y < 0.0f
                    ||  position.y > 1.0f
                    ||  position.z < 0.0f
                    ||  position.z > 1.0f) { break; }

                    float4 source = tex3Dlod(_Texture, float4(position.x, position.y, position.z, _Frame));
                    if (i == 0) { previous = source; }
                    //output = (previous + source) * 0.5f;
                    output.rgb = (source.rgb * 0.5f) + (1.0f - source.a) * (output.rgb);
                    output.a = (source.a * 0.5f) + (1.0f - source.a) * output.a;
                    previous = source;
                }
                return output;
            }
            ENDCG
        }
    }
}
