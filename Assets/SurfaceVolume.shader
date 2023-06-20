Shader "Custom/SurfaceVolume"
{
    Properties
    {
        _Texture ("Albedo (RGB)", 3D) = "" {}
        _Steps("Steps", Float) = 512
        _Frame("Frame", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "LightMode" = "Always" }
        Cull Front

        CGPROGRAM
        #pragma target 4.0
        #pragma surface surface_shader Off vertex:vertex_shader alpha:auto

        sampler3D _Texture;
        uint _Steps;
        uint _Frame;

        struct Input { float3 viewDir; float3 pixel; };

        void vertex_shader(inout appdata_full input, out Input output)
        {
            UNITY_INITIALIZE_OUTPUT(Input, output);
            output.pixel = input.vertex.xyz;
        }

        float4 LightingOff(SurfaceOutput input, float3 direction, float attenuation)
        {
            return float4(input.Albedo, input.Alpha);
        }

        void surface_shader(Input input, inout SurfaceOutput output)
        {
            float4 fragment = float4(0.0f, 0.0f, 0.0f, 0.0f);
            float4 previous = float4(0.0f, 0.0f, 0.0f, 0.0f);
            int tmp = _Steps; if (tmp < 0) { tmp = 0; }
            uint steps = tmp;
            float stride = 2.0f / steps;

            float3 origin = input.pixel + float3(0.5f, 0.5f, 0.5f);
            float3 direction = input.viewDir;

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
                //fragment = (previous + source) * 0.5f;
                fragment.rgb = (source.rgb * 0.5f) + (1.0f - source.a) * (fragment.rgb);
                fragment.a = (source.a * 0.5f) + (1.0f - source.a) * fragment.a;
                previous = source;
            }
            output.Albedo = fragment.rgb;
            output.Alpha = fragment.a;
        }
        ENDCG
    }
}
