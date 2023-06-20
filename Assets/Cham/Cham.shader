Shader "PixelFire/Cham"
{
    Properties
    {
        _Texture("Texture", 3D) = "" {}
        _Glossiness("Smoothness", Range(0.0, 1.0)) = 1.0
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _Color("Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _Steps("Steps", Float) = 4096
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front ZWrite Off ZTest LEqual //Not Equal

        CGPROGRAM
        #pragma surface surface Standard fullforwardshadows alpha:blend vertex:vertex
        #define ONE_EIGHTH (1.0 / 8.0)

        sampler3D _Texture;
        fixed _Glossiness;
        fixed _Metallic;
        fixed4 _Color;
        int _Steps;

        struct Input { fixed3 viewDir; fixed3 pixel; };

        void vertex(inout appdata_full input, out Input output)
        {
            UNITY_INITIALIZE_OUTPUT(Input, output);
            output.pixel = input.vertex.xyz;
        }

        void surface(Input input, inout SurfaceOutputStandard output)
        {
            fixed4 fragment = 0.0;
            int tmp = _Steps; if (tmp < 0) { tmp = 0; }
            uint steps = tmp;
            fixed stride = 2.0 / steps;

            fixed3 origin = input.pixel + 0.5;
            fixed3 direction = input.viewDir;

            origin += direction * stride;

            for (uint i = 0; i < steps; ++i)
            {
                fixed3 position = origin + (direction * (i * stride));
                if (position.x < 0.0 || position.x > 1.0
                ||  position.y < 0.0 || position.y > 1.0
                ||  position.z < 0.0 || position.z > 1.0) { break; }

                //if (position.x % (1.0 / 8.0) < 0.05) { continue; }
                //fixed3 coord = (position.xyz % ONE_EIGHTH) * 8.0;
                //if (coord.x < 0.5) { continue; }

                //if (coord.x < 0.1 || coord.x > 0.9
                //||  coord.y < 0.1 || coord.y > 0.9
                //||  coord.z < 0.1 || coord.z > 0.9) { continue; }

                fixed3 offset = ((position.xyz % ONE_EIGHTH) * 8.0) - 0.5;
                fixed radius = sqrt(pow(offset.x, 2) + pow(offset.y, 2) + pow(offset.z, 2));
                if (pow(radius, 2) > 0.5) { continue; }

                fixed4 source = tex3Dlod(_Texture, fixed4(position.x, position.y, position.z, 0.0)) + _Color;
                fragment.rgb = source.rgb + ((1.0 - source.a) * fragment.rgb);
                fragment.a = source.a + ((1.0 - source.a) * fragment.a);
            }
            output.Albedo = fragment.rgb;
            output.Alpha = fragment.a;
            output.Metallic = _Metallic;
            output.Smoothness = _Glossiness;
        }
/*
        void surface(Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex3Dlod(_Texture, fixed4(IN.worldPos.xyz - 0.05, 0.0)) + _Color;
            o.Alpha = c.a;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
*/
        ENDCG
    }
}
