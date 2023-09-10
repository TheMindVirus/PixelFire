Shader "PixelFire/Hemi"
{
    Properties
    {
        _Texture("Texture", 3D) = "" {}
        _Color("Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _Steps("Steps", Float) = 4096
        _Debug("Debug", Range(0, 1)) = 1.0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front ZWrite Off ZTest LEqual //Not Equal

        CGPROGRAM
        #pragma surface surface Off alpha:blend vertex:vertex noambient

        sampler3D _Texture;
        fixed4 _Color;
        int _Steps;
        fixed _Debug;

        struct Input { fixed3 viewDir; fixed3 pixel; fixed3 normal; };

        fixed4 LightingOff(SurfaceOutput input, fixed3 direction, fixed attenuation)
        {
            return fixed4(input.Albedo, input.Alpha);
        }

        void vertex(inout appdata_full input, out Input output)
        {
            UNITY_INITIALIZE_OUTPUT(Input, output);
            output.pixel = input.vertex.xyz;
            output.normal = input.normal; //UnityObjectToWorldNormal(input.vertex);
        }

        void surface(Input input, inout SurfaceOutput output)
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
                fixed3 pos = origin + (direction * (i * stride));
                if (pos.x < 0.0 || pos.x > 1.0
                ||  pos.y < 0.0 || pos.y > 1.0
                ||  pos.z < 0.0 || pos.z > 1.0) { break; }

                fixed3 o = (pos * 2.0) - 1.0;
                fixed lhs = (o.x * o.x) + (o.y * o.y) + (o.z * o.z);
                fixed rhs = 1.0;
                fixed diff = lhs - rhs;
                if (diff > 0) { continue; }
                //fixed thicc = 0.05;
                //if (diff > thicc || diff < -thicc) { continue; }

                if (pos.x < 0.5 ) { continue; }

                fixed4 src = _Color - abs(diff);
                //fragment.rgb = src.rgb + ((1.0 - src.a) * fragment.rgb);
                //fragment.a = src.a + ((1.0 - src.a) * fragment.a);
                fragment.rgb = (src.rgb * src.a) + (fragment.rgb * (1.0 - src.a - 0.00125));
                fragment.a = (src.a * src.a) + (fragment.a * (1.0 - src.a));
            }
            output.Albedo = fragment.rgb;
            output.Alpha = fragment.a;
        }
        ENDCG
    }
}
