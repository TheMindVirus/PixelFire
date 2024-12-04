Shader "PixelFire/Alpha1"
{
    Properties
    {
        _Texture("Texture", 3D) = "" {}
        _Color("Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _Steps("Steps", Float) = 4096
        _Debug("Debug", Vector) = (0.0, 0.0, 0.0, 0.0)
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

            fixed blend = (8.0 / steps); //at maximum, an approximation of the average layer alpha depth

            for (uint i = 0; i < steps; ++i)
            {
                fixed3 pos = origin + (direction * (i * stride));
                if (pos.x < 0.0 || pos.x > 1.0
                ||  pos.y < 0.0 || pos.y > 1.0
                ||  pos.z < 0.0 || pos.z > 1.0) { break; }

                fixed3 offset = ((pos.xyz % ONE_EIGHTH) * 8.0) - 0.5;
                fixed radius = sqrt(pow(offset.x, 2) + pow(offset.y, 2) + pow(offset.z, 2));
                //if ((offset.x + _Debug.x) > (radius * _Debug.w)) { continue; }
                if (!cham(offset, ONE_EIGHTH)) { continue; }
                //if (((offset.x > 0.3) && (offset.y > 0.3)) && ((radius + 0.3) )) { continue; }

                fixed4 src = tex3Dlod(_Texture, fixed4(pos.x, pos.y, pos.z, 0.0)) + _Color;
                fixed4 dst = fixed4(pos.xyz - origin.xyz, 1.0);
                //fixed3 dst = ((pos.xyz - origin.xyz) % ONE_EIGHTH) * 8.0;
                src = dst;

                fixed depth = stride; //dst.x * dst.y * dst.z;
                //fixed depth = sqrt(pow(dst.x, 2) + pow(dst.y, 2) + pow(dst.z, 2));
                //fixed4 voxel = fixed4(dst.x, dst.y, dst.z, depth * 0.001);
                fixed4 voxel = fixed4(depth, depth, depth, depth);
                //src = fixed4(max(0.0, dst.x), max(0.0, dst.y), max(0.0, dst.z), 1.0);
                //src = max(max(dst.x, dst.y), dst.z);

                fragment.rgb = src.rgb + ((1.0 - src.a) * fragment.rgb);
                fragment.a = src.a + ((1.0 - src.a) * fragment.a);




                //fixed alpha = (1.0 - dst.a) * src.a;
                //fragment.rgb = src.rgb + ((1.0 - src.a) * fragment.rgb);
                //fragment.a = alpha + ((1.0 - alpha) * fragment.a);

                //fixed alpha = (src.a) * (1.0 / steps);
                //fragment.rgb = src.rgb + ((1.0 - src.a) * fragment.rgb);
                //fragment.a = alpha + ((1.0 - alpha) * fragment.a);

                //fragment.rgb = src.rgb + ((1.0 - src.a) * fragment.rgb);
                //dst.a *= blend;
                //fragment.a = dst.a + ((1.0 - src.a) * fragment.a);




/*

                fixed4 src = tex3Dlod(_Texture, fixed4(pos.x, pos.y, pos.z, 0.0)) + _Color;
                //if (src.a != 1.0) { continue; }
                //if ((src.a != 1.0) && (src.a != 0.0)) { src.a = 8.0 / steps; }
//src.a *= blend;
                fragment.rgb = src.rgb + ((1.0 - src.a) * fragment.rgb);
src.a *= blend;
                fragment.a = src.a + ((1.0 - src.a) * fragment.a);
*/
            }
            output.Albedo = fragment.rgb;
            output.Alpha = fragment.a;
        }
        ENDCG
    }
}
