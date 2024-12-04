Shader "PixelFire/Chamallow"
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
                fixed3 pos = origin + (direction * (i * stride));
                if (pos.x < 0.0 || pos.x > 1.0
                ||  pos.y < 0.0 || pos.y > 1.0
                ||  pos.z < 0.0 || pos.z > 1.0) { break; }

                fixed3 offset = ((pos.xyz % ONE_EIGHTH) * 8.0) - 0.5;
                if (!cham(offset, ONE_EIGHTH)) { continue; }

                fixed4 src = tex3Dlod(_Texture, fixed4(pos.x, pos.y, pos.z, 0.0)) + _Color;
                fixed4 dst = fixed4(pos.xyz - origin.xyz, 1.0);

                fragment.rgb = src.rgb + ((1.0 - src.a) * fragment.rgb);
                fragment.a = src.a + ((1.0 - src.a) * fragment.a);
            }
            output.Albedo = fragment.rgb;
            output.Alpha = fragment.a;
        }
        ENDCG
    }
}
