Shader "Custom/GLSL"
{
    Properties
    {
        _Color("Colour", Color) = (1.0, 1.0, 1.0, 1.0)
        _Texture("Texture", 3D) = "" {}
        _Steps("Steps", Float) = 512
        _Frame("Frame", Float) = 0
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZWrite Off

            GLSLPROGRAM
            #include "UnityCG.glslinc"

            uniform vec4 _Color;
            uniform sampler3D _Texture;
            uniform float _Steps;
            uniform float _Frame;

#ifdef VERTEX
            out vec3 texcoord;
            out vec3 direction;

            vec3 ObjSpaceViewDirVertex(vec4 pos)
            {
                vec3 objSpaceCameraPos = (unity_WorldToObject * vec4(_WorldSpaceCameraPos.xyz, 1.0)).xyz;
                return objSpaceCameraPos - pos.xyz;
            }

            void main()
            {
                gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
                texcoord = gl_Vertex.xyz;
                //direction = normalize(ObjSpaceViewDir(gl_Vertex));
                direction = ObjSpaceViewDirVertex(gl_Vertex);
            }
#endif

#ifdef FRAGMENT
            in vec3 texcoord;
            in vec3 direction;

            vec3 ObjSpaceViewDirFragment(vec4 pos)
            {
                vec3 objSpaceCameraPos = (unity_WorldToObject * vec4(_WorldSpaceCameraPos.xyz, 1.0)).xyz;
                return objSpaceCameraPos - pos.xyz;
            }

            void main()
            {
                vec4 fragment;
                int tmp = int(_Steps); if (tmp < 0) { tmp = 0; } 
                uint steps = uint(tmp);
                const float stride = 2.0f / steps;

                vec3 origin = texcoord + vec3(0.5, 0.5, 0.5);
                //vec3 direction = ObjSpaceViewDirFragment(vec4(texcoord, 0.0));

                origin += normalize(direction) * stride;

                for (uint i = 0; i < steps; ++i)
                {
                    vec3 position = origin + normalize(direction) * (i * stride);
                    if (position.x < 0.0
                    ||  position.x > 1.0
                    ||  position.y < 0.0
                    ||  position.y > 1.0
                    ||  position.z < 0.0
                    ||  position.z > 1.0) { break; }

                    //vec4 source = vec4(0.0, 0.0, 1.0, 0.5);
                    vec4 source = texture3DLod(_Texture, position, _Frame);
                    fragment.rgb = (source.rgb * 0.5) + (1.0 - source.a) * fragment.rgb;
                    fragment.a = (source.a * 0.5) + (1.0 - source.a) * fragment.a;
                }
                gl_FragColor = fragment;
            }
#endif

            ENDGLSL
        }
    }
}
