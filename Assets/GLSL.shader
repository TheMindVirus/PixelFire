Shader "Custom/GLSL"
{
    Properties
    {
        _Color("Colour", Color) = (1.0, 1.0, 1.0, 1.0)
        _Texture("Texture", 3D) = "" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            GLSLPROGRAM
            #ifdef VERTEX
            //uniform float4 _Color;
            //uniform sampler3D _Texture;
            //attribute vec4 Tangent;
            //varying vec3 lightDir;
            void main()
            {
                //gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
            }
            #endif
            #ifdef FRAGMENT
            //varying vec3 lightDir;
            void main()
            {
                //gl_FragData[0] = textureExternal(_MainTex, uv);
                //gl_FragColor = vec4(0.0, 0.0, 1.0, 1.0);
            }
            #endif
            ENDGLSL
        }
    }
}
