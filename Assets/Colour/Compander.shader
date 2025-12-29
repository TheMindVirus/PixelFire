Shader "Hidden/Compander"
{
    Properties
    {
        _Chroma1 ("Chroma1", Color) = (0.0, 1.0, 0.0, 1.0)
        _Chroma2 ("Chroma2", Color) = (0.0, 0.0, 1.0, 1.0)
        _Texture1 ("Texture1", 2D) = "black" {} //added-file-dark@2x.png
        _Texture2 ("Texture2", 2D) = "black" {} //back-dark@2x.png
        _Chroma3 ("Chroma3", Color) = (1.0, 1.0, 1.0, 1.0)
        _Chroma4 ("Chroma4", Color) = (0.0, 0.0, 0.0, 0.0)
        _Chroma1_Mix ("Mix Chroma1", Vector) = (1.0, 1.0, 1.0, 1.0)
        _Chroma2_Mix ("Mix Chroma2", Vector) = (1.0, 1.0, 1.0, 1.0)
        _Texture1_Mix ("Mix Texture1", Vector) = (1.0, 1.0, 1.0, 4.0)
        _Texture2_Mix ("Mix Texture2", Vector) = (0.0, 0.0, 0.0, 0.0)
        _Multiply ("Multiply", Vector) = (1.0, 1.0, 1.0, 1.0)
        _Add ("Add", Vector) = (0.0, 0.0, 0.0, 0.0)
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vertex
            #pragma fragment fragment
            #include "UnityCG.cginc"

            fixed4 _Chroma1;
            fixed4 _Chroma2;
            sampler2D _Texture1;
            sampler2D _Texture2;
            fixed4 _Texture1_ST;
            fixed4 _Texture2_ST;
            fixed4 _Chroma3;
            fixed4 _Chroma4;
            fixed4 _Chroma1_Mix;
            fixed4 _Chroma2_Mix;
            fixed4 _Texture1_Mix;
            fixed4 _Texture2_Mix;
            fixed4 _Multiply;
            fixed4 _Add;

            fixed blend(fixed a, fixed b, fixed c)
            {
                return (a * c) + (b * (1.0 - c));
            }

            fixed compand(fixed a)
            {
                if (a >= 0.0) { return 1.0 - (0.5 * a); }
                else { return 1.0 - (-0.5 * a); }
            }

            fixed4 mix(fixed4 a, fixed4 b, fixed4 mode)
            {
                fixed4 c = fixed4(0.0, 0.0, 0.0, 0.0);
                if ((mode.r >= 0.0) && (mode.r < 1.0)) { c.r = blend(a.r, b.r, 0.5); }
                if ((mode.g >= 0.0) && (mode.g < 1.0)) { c.g = blend(a.g, b.g, 0.5); }
                if ((mode.b >= 0.0) && (mode.b < 1.0)) { c.b = blend(a.b, b.b, 0.5); }
                if ((mode.a >= 0.0) && (mode.a < 1.0)) { c.a = blend(a.a, b.a, 0.5); }
                if ((mode.r >= 1.0) && (mode.r < 2.0)) { c.r = (a.r * compand(b.r)) + (b.r * compand(a.r)); }
                if ((mode.g >= 1.0) && (mode.g < 2.0)) { c.g = (a.g * compand(b.g)) + (b.g * compand(a.g)); }
                if ((mode.b >= 1.0) && (mode.b < 2.0)) { c.b = (a.b * compand(b.b)) + (b.b * compand(a.b)); }
                if ((mode.a >= 1.0) && (mode.a < 2.0)) { c.a = (a.a * compand(b.a)) + (b.a * compand(a.a)); }
                if ((mode.r >= 2.0) && (mode.r < 3.0)) { c.r = (a.r * (1.0 - b.r)) + (b.r * (1.0 - a.r)); }
                if ((mode.g >= 2.0) && (mode.g < 3.0)) { c.g = (a.g * (1.0 - b.g)) + (b.g * (1.0 - a.g)); }
                if ((mode.b >= 2.0) && (mode.b < 3.0)) { c.b = (a.b * (1.0 - b.b)) + (b.b * (1.0 - a.b)); }
                if ((mode.a >= 2.0) && (mode.a < 3.0)) { c.a = (a.a * (1.0 - b.a)) + (b.a * (1.0 - a.a)); }
                if ((mode.r >= 3.0) && (mode.r < 4.0)) { c.r = (a.r > b.r) ? a.r : b.r; }
                if ((mode.g >= 3.0) && (mode.g < 4.0)) { c.g = (a.g > b.g) ? a.g : b.g; }
                if ((mode.b >= 3.0) && (mode.b < 4.0)) { c.b = (a.b > b.b) ? a.b : b.b; }
                if ((mode.a >= 3.0) && (mode.a < 4.0)) { c.a = (a.a > b.a) ? a.a : b.a; }
                if ((mode.r >= 4.0) && (mode.r < 5.0)) { c.r = (a.r < b.r) ? a.r : b.r; }
                if ((mode.g >= 4.0) && (mode.g < 5.0)) { c.g = (a.g < b.g) ? a.g : b.g; }
                if ((mode.b >= 4.0) && (mode.b < 5.0)) { c.b = (a.b < b.b) ? a.b : b.b; }
                if ((mode.a >= 4.0) && (mode.a < 5.0)) { c.a = (a.a < b.a) ? a.a : b.a; }
                if ((mode.r >= 5.0) && (mode.r < 6.0)) { c.r = (a.r >= b.r) ? a.r : b.r; }
                if ((mode.g >= 5.0) && (mode.g < 6.0)) { c.g = (a.g >= b.g) ? a.g : b.g; }
                if ((mode.b >= 5.0) && (mode.b < 6.0)) { c.b = (a.b >= b.b) ? a.b : b.b; }
                if ((mode.a >= 5.0) && (mode.a < 6.0)) { c.a = (a.a >= b.a) ? a.a : b.a; }
                if ((mode.r >= 6.0) && (mode.r < 7.0)) { c.r = (a.r <= b.r) ? a.r : b.r; }
                if ((mode.g >= 6.0) && (mode.g < 7.0)) { c.g = (a.g <= b.g) ? a.g : b.g; }
                if ((mode.b >= 6.0) && (mode.b < 7.0)) { c.b = (a.b <= b.b) ? a.b : b.b; }
                if ((mode.a >= 6.0) && (mode.a < 7.0)) { c.a = (a.a <= b.a) ? a.a : b.a; }
                return c;
            }

            appdata_full vertex(appdata_full input)
            {
                appdata_full output = input;
                output.vertex = UnityObjectToClipPos(input.vertex);
                return output;
            }

            fixed4 fragment(appdata_full input) : SV_Target
            {
                fixed4 c = fixed4(0.0, 0.0, 0.0, 0.0);
                fixed4 __Texture1 = tex2D(_Texture1, (input.texcoord.xy * _Texture1_ST.xy) + _Texture1_ST.zw);
                fixed4 __Texture2 = tex2D(_Texture2, (input.texcoord.xy * _Texture2_ST.xy) + _Texture2_ST.zw);
                c = mix(c, _Chroma1, _Chroma1_Mix);
                c = mix(c, _Chroma2, _Chroma2_Mix);
                c = mix(c, __Texture1, _Texture1_Mix);
                c = mix(c, __Texture2, _Texture2_Mix);
                c *= _Chroma3;
                c += _Chroma4;
                c *= _Multiply;
                c += _Add;
                return c;
            }
            ENDCG
        }
    }
}
