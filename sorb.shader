Shader "PixelFire/sorb"
{
    Properties
    {
        _Texture("Texture", 3D) = "" {}
        _Color("Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _Steps("Steps", Float) = 512
        _Sorb("Sorb", Range(0.0, 0.00125)) = 0.0
        _Debug("Debug", Vector) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front ZWrite Off ZTest LEqual //Not Equal

        CGPROGRAM
        #pragma surface surface Off alpha:blend vertex:vertex noambient
        #define ONE_EIGHTH 0.125 //(1.0 / 8.0)

        sampler3D _Texture;
        fixed4 _Color;
        int _Steps;
        fixed _Sorb; //Internal Ambient Occlusion, Energy Loss incurred from Material Alloy and Chromatic Dispersion
        fixed4 _Debug;

        struct Input { fixed3 viewDir; fixed3 pixel; fixed3 normal; };

        fixed4 LightingOff(SurfaceOutput input, fixed3 direction, fixed attenuation)
        {
            return fixed4(input.Albedo, input.Alpha);
        }

        fixed cham(fixed3 offset, fixed radius)
        {
            fixed retval = 0.0;
            fixed corner = 0.5 - radius;

            if ((offset.x < corner) && (offset.x > -corner)
            &&  (offset.y < corner) && (offset.y > -corner)
            &&  (offset.z < corner) && (offset.z > -corner)) { retval = 1.0; }

            if ((offset.z < corner) && (offset.z > -corner) && (sqrt(pow(offset.x + corner, 2) + pow(offset.y - corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.z < corner) && (offset.z > -corner) && (sqrt(pow(offset.x + corner, 2) + pow(offset.y + corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.z < corner) && (offset.z > -corner) && (sqrt(pow(offset.x - corner, 2) + pow(offset.y + corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.z < corner) && (offset.z > -corner) && (sqrt(pow(offset.x - corner, 2) + pow(offset.y - corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.x < corner) && (offset.x > -corner) && (sqrt(pow(offset.y + corner, 2) + pow(offset.z - corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.x < corner) && (offset.x > -corner) && (sqrt(pow(offset.y + corner, 2) + pow(offset.z + corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.x < corner) && (offset.x > -corner) && (sqrt(pow(offset.y - corner, 2) + pow(offset.z + corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.x < corner) && (offset.x > -corner) && (sqrt(pow(offset.y - corner, 2) + pow(offset.z - corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.y < corner) && (offset.y > -corner) && (sqrt(pow(offset.z + corner, 2) + pow(offset.x - corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.y < corner) && (offset.y > -corner) && (sqrt(pow(offset.z + corner, 2) + pow(offset.x + corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.y < corner) && (offset.y > -corner) && (sqrt(pow(offset.z - corner, 2) + pow(offset.x + corner, 2)) < radius)) { retval = 1.0; }
            if ((offset.y < corner) && (offset.y > -corner) && (sqrt(pow(offset.z - corner, 2) + pow(offset.x - corner, 2)) < radius)) { retval = 1.0; }

            if (((offset.x < -corner) && (offset.y < -corner) && (offset.z < -corner)) && (sqrt(pow(offset.x + corner, 2) + pow(offset.y + corner, 2) + pow(offset.z + corner, 2)) < radius)) { retval = 1.0; }
            if (((offset.x < -corner) && (offset.y < -corner) && (offset.z >  corner)) && (sqrt(pow(offset.x + corner, 2) + pow(offset.y + corner, 2) + pow(offset.z - corner, 2)) < radius)) { retval = 1.0; }
            if (((offset.x < -corner) && (offset.y >  corner) && (offset.z < -corner)) && (sqrt(pow(offset.x + corner, 2) + pow(offset.y - corner, 2) + pow(offset.z + corner, 2)) < radius)) { retval = 1.0; }
            if (((offset.x < -corner) && (offset.y >  corner) && (offset.z >  corner)) && (sqrt(pow(offset.x + corner, 2) + pow(offset.y - corner, 2) + pow(offset.z - corner, 2)) < radius)) { retval = 1.0; }
            if (((offset.x >  corner) && (offset.y < -corner) && (offset.z < -corner)) && (sqrt(pow(offset.x - corner, 2) + pow(offset.y + corner, 2) + pow(offset.z + corner, 2)) < radius)) { retval = 1.0; }
            if (((offset.x >  corner) && (offset.y < -corner) && (offset.z >  corner)) && (sqrt(pow(offset.x - corner, 2) + pow(offset.y + corner, 2) + pow(offset.z - corner, 2)) < radius)) { retval = 1.0; }
            if (((offset.x >  corner) && (offset.y >  corner) && (offset.z < -corner)) && (sqrt(pow(offset.x - corner, 2) + pow(offset.y - corner, 2) + pow(offset.z + corner, 2)) < radius)) { retval = 1.0; }
            if (((offset.x >  corner) && (offset.y >  corner) && (offset.z >  corner)) && (sqrt(pow(offset.x - corner, 2) + pow(offset.y - corner, 2) + pow(offset.z - corner, 2)) < radius)) { retval = 1.0; }

            return retval;
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
if (i >= (uint)_Debug.w) { break; }
                fixed3 pos = origin + (direction * (i * stride));
                if (pos.x < 0.0 || pos.x > 1.0
                ||  pos.y < 0.0 || pos.y > 1.0
                ||  pos.z < 0.0 || pos.z > 1.0) { break; }

                //fixed3 offset = ((pos.xyz % ONE_EIGHTH) * 8.0) - 0.5;
                //if (!cham(offset, ONE_EIGHTH)) { continue; }

                //fixed radius = sqrt(pow(offset.x, 2) + pow(offset.y, 2) + pow(offset.z, 2));
                //if (radius > ONE_EIGHTH) { continue; } //add scale property to cham instead

                fixed4 src = tex3Dlod(_Texture, fixed4(pos.x, pos.y, pos.z, 0.0)) + _Color;
                fixed4 dst = fixed4(pos.xyz - origin.xyz, 1.0);

                //src = dst;
                fixed depth = (dst.x + dst.y + dst.z) / 3.0;
                fixed alpha = depth * (1.0 / steps);
                //src.a -= min(src.a, 0.5);

                //fragment.rgb = src.rgb + ((1.0 - src.a) * fragment.rgb);
                //fragment.a = src.a + ((1.0 - src.a) * fragment.a);

                //fragment.rgb = (src.rgb * 0.5) + (fragment.rgb * 0.5);
                //fragment.a = (src.a * 0.5) + (fragment.a * 0.5);

                //fragment.rgb = (src.rgb * src.a) + (fragment.rgb * (1.0 - src.a));
                //fragment.a = (src.a * src.a) + (fragment.a * (1.0 - src.a));

                fragment.rgb = (src.rgb * src.a) + (fragment.rgb * (1.0 - src.a - _Sorb));
                fragment.a = (src.a * src.a) + (fragment.a * (1.0 - src.a));
            }
            output.Albedo = fragment.rgb;
            output.Alpha = fragment.a;
        }
        ENDCG
    }
}
