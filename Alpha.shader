Shader "PixelFire/Alpha"
{
    Properties
    {
        _Texture("Texture", 3D) = "" {}
        _Color("Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _Steps("Steps", Float) = 4096
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front ZWrite Off ZTest LEqual //Not Equal

        CGPROGRAM
        #pragma surface surface Off alpha:blend vertex:vertex noambient
        #define ONE_EIGHTH (1.0 / 8.0)

        sampler3D _Texture;
        fixed4 _Color;
        int _Steps;

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

            fixed blend = (8.0 / steps); //at maximum, an approximation of the average layer alpha depth

            for (uint i = 0; i < steps; ++i)
            {
                fixed3 position = origin + (direction * (i * stride));
                if (position.x < 0.0 || position.x > 1.0
                ||  position.y < 0.0 || position.y > 1.0
                ||  position.z < 0.0 || position.z > 1.0) { break; }

                //fixed3 offset = ((position.xyz % ONE_EIGHTH) * 8.0) - 0.5;
                //fixed radius = sqrt(pow(offset.x, 2) + pow(offset.y, 2) + pow(offset.z, 2));
                //if (pow(radius, 2) > 0.5) { continue; }

                fixed4 source = tex3Dlod(_Texture, fixed4(position.x, position.y, position.z, 0.0)) + _Color;
                //if (source.a != 1.0) { continue; }
                //if ((source.a != 1.0) && (source.a != 0.0)) { source.a = 8.0 / steps; }
//source.a *= blend;
                fragment.rgb = source.rgb + ((1.0 - source.a) * fragment.rgb);
source.a *= blend;
                fragment.a = source.a + ((1.0 - source.a) * fragment.a);
            }
            output.Albedo = fragment.rgb;
            output.Alpha = fragment.a;
        }
        ENDCG
    }
}
