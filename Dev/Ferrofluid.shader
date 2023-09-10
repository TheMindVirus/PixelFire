Shader "PixelFire/Ferrofluid"
{
    Properties
    {
        _Color("Color", Color) = (1.0, 1.0, 1.0, 0.3)
        _Steps("Steps", Float) = 512
        _DebugPhase("Phase", Float) = 8.00
        _DebugScale("Scale", Float) = 0.03
        _DebugNormal("Normal", Vector) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" "IgnoreProjector" = "True" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front ZWrite Off ZTest LEqual //Not Equal

        CGPROGRAM
        #define T 0.15915494309189535
        #define ONE_THIRD 0.33333333333333333
        #define ONE_EIGHTH 0.125
        #pragma surface surface Off alpha:blend vertex:vertex noambient

        fixed4 _Color;
        int _Steps;
        fixed _DebugPhase;
        fixed _DebugScale;
        fixed4 _DebugNormal;

        struct Input { fixed3 viewDir; fixed3 pixel; fixed3 normal; };

        fixed4 LightingOff(SurfaceOutput input, fixed3 direction, fixed attenuation)
        {
            return fixed4(input.Albedo, input.Alpha);
        }

        void vertex(inout appdata_full input, out Input output)
        {
            UNITY_INITIALIZE_OUTPUT(Input, output);
            output.pixel = input.vertex.xyz;
            output.normal = input.normal;
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

                bool skip = false;

                fixed3 o = (pos * 2.0) - 1.0;
                fixed a1 = atan(abs(o.y) / abs(o.x)); //angle
                fixed a2 = atan(abs(o.z) / abs(o.y)); //angle
                fixed a3 = atan(abs(o.x) / abs(o.z)); //angle
                fixed s = sin(a1 * _DebugPhase) + sin(a2 * _DebugPhase) + sin(a3 * _DebugPhase);
                fixed v = s * _DebugScale;
                fixed n = (ONE_EIGHTH * s) + _DebugNormal.xyz;
                fixed lhs = (o.x * o.x) + (o.y * o.y) + (o.z * o.z);
                fixed rhs = (ONE_THIRD + v);
                rhs *= rhs;
                fixed eq = lhs - rhs;
                bool b = (eq > 0.0);
                skip = skip | b;
                //skip |= b;

                if (skip) { continue; }

                fixed4 src = _Color;
                //fixed4 normal = UnityObjectToWorldNormal(pos);
                src += fixed4(n, n, n, _DebugNormal.w);
                fragment.rgb = (src.rgb * src.a) + (fragment.rgb * (1.0 - src.a - 0.00125));
                fragment.a = (src.a * src.a) + (fragment.a * (1.0 - src.a));
            }
            output.Albedo = fragment.rgb;
            output.Alpha = fragment.a;
        }
        ENDCG
    }
}
