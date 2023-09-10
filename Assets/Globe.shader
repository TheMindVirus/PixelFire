Shader "PixelFire/Globe"
{
    Properties
    {
        _Texture("Texture", 3D) = "" {}
        _Color("Color", Color) = (0.0, 0.0, 0.0, 0.0)
        _Steps("Steps", Float) = 100
        _Intensity("Intensity", Float) = 1.0
        _Debug("Debug", Range(0, 1)) = 1.0
        _DebugScale("Scale", Float) = 2.0
        _DebugTranslation("Translate", Vector) = (1.0, 0.0, 0.0, 0.0)
        _DebugRotation("Rotate", Vector) = (0.0, 0.0, 0.0, 0.0)
        _DebugPivot("Pivot", Vector) = (0.0, 0.0, 0.0, 0.0)
        [Toggle] _ToggleTextured("Textured", Int) = 0
        [Toggle] _ToggleIntersect("Intersect", Int) = 1
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front ZWrite Off ZTest LEqual //Not Equal

        CGPROGRAM
        #define T 0.15915494309189535
        #pragma surface surface Off alpha:blend vertex:vertex noambient

        sampler3D _Texture;
        fixed4 _Texture_ST;
        fixed4 _Color;
        int _Steps;
        fixed _Intensity;
        fixed _Debug;
        fixed _DebugScale;
        fixed4 _DebugTranslation;
        fixed4 _DebugRotation;
        fixed4 _DebugPivot;
        bool _ToggleTextured;
        bool _ToggleIntersect;

        struct Input { fixed3 viewDir; fixed3 pixel; fixed3 normal; };

        fixed4 LightingOff(SurfaceOutput input, fixed3 direction, fixed attenuation)
        {
            return fixed4(input.Albedo, input.Alpha);
        }

        fixed3 rotate(fixed3 pos, fixed3 value, fixed3 pivot = fixed3(0.0, 0.0, 0.0))
        {
            fixed3 remap = fixed3(value.x / T, value.y / T, value.z / T);
            fixed3 moved = pos - pivot;
            fixed3x3 _matrix;
            _matrix[0].x = cos(remap.x) * cos(remap.z);
            _matrix[0].y = (-1.0 * cos(remap.y) * sin(remap.z)) + (sin(remap.y) * sin(remap.x) * cos(remap.z));
            _matrix[0].z = (sin(remap.y) * sin(remap.z)) + (cos(remap.y) * sin(remap.x) * cos(remap.z));
            _matrix[1].x = cos(remap.x) * sin(remap.z);
            _matrix[1].y = (cos(remap.y) * cos(remap.z)) + (sin(remap.y) * sin(remap.x) * sin(remap.z));
            _matrix[1].z = (-1.0 * sin(remap.y) * cos(remap.z)) + (cos(remap.y) * sin(remap.x) * sin(remap.z));
            _matrix[2].x = (-1.0 * sin(remap.x));
            _matrix[2].y = sin(remap.y) * cos(remap.x);
            _matrix[2].z = cos(remap.y) * cos(remap.x);
            fixed3 rotated = fixed3((moved.x * _matrix[0].x) + (moved.y * _matrix[0].y) + (moved.z * _matrix[0].z),
                                    (moved.x * _matrix[1].x) + (moved.y * _matrix[1].y) + (moved.z * _matrix[1].z),
                                    (moved.x * _matrix[2].x) + (moved.y * _matrix[2].y) + (moved.z * _matrix[2].z));
            return rotated + pivot;
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

                fixed3 o1 = (pos * 2.0) - 1.0;
                fixed lhs1 = (o1.x * o1.x) + (o1.y * o1.y) + (o1.z * o1.z);
                fixed rhs1 = 1.0;
                fixed f1 = lhs1 - rhs1;
                bool b1 = (f1 > 0.0);

                fixed3 o2 = (pos * -2.0) + 1.0;
                fixed r2 = (_Time.xyz % 1.0) + _DebugRotation.xyz;
                fixed d2 = _DebugTranslation.xyz + _DebugPivot.xyz;
                o2 += _DebugTranslation.xyz;
                o2 = rotate(o2, r2, d2);
                fixed lhs2 = (o2.x * o2.x) + (o2.y * o2.y) + (o2.z * o2.z);
                fixed rhs2 = (_Time.w % _DebugScale) * _DebugScale;
                fixed f2 = lhs2 - rhs2;
                bool b2 = (f2 > 0.0);

                if (!_ToggleIntersect) { if (b2) { continue; } }
                else { if (b1 || b2) { continue; } }

                fixed4 src = _Color;
                if (_ToggleTextured) { src = tex3Dlod(_Texture, fixed4(pos.xyz, 0.0)); src.a *= (_Intensity * 0.0005); }
                fragment.rgb = src.rgb + ((1.0 - src.a) * fragment.rgb);
                fragment.a = src.a + ((1.0 - src.a) * fragment.a);
            }
            output.Albedo = fragment.rgb;
            output.Alpha = fragment.a;
        }
        ENDCG
    }
}
