Shader "VolumeRendering/SwarmVolumeShader"
{
    Properties
    {
        _Color("Colour", Color) = (1,1,1,1)
        _Texture("Texture", 3D) = ""
        _Steps("Steps", Float) = 512 //reduce to 100 for mobile devices
        _Frame("Frame", Float) = 0
        _DebugOrigin("DebugOrigin", Vector) = (0,0,0,0)
        _DebugDirection("DebugDirection", Vector) = (0,0,0,0)
        _DebugScale("DebugScale", Vector) = (1,1,1,1)
        _DebugView("DebugView", Vector) = (1,1,1,1)
        _DebugAlpha("DebugAlpha", Vector) = (0.5,0.5,1.0,1.0)
    }
    SubShader //Input Vertex Data is Wildly Offset by known value...Per Particle Position...
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Opaque" } //Contradictory
        Blend SrcAlpha OneMinusSrcAlpha //Required for Transparency
        Cull Front //Required to render on the inside of the cube
        ZWrite Off //Required to remove border Alpha glitches
        ZTest LEqual //NotEqual

        //RenderAlignment of particles must be = "World", Custom Vertex Streams = Off, Enable Mesh GPU Instancing = On
        //3D Start Position and 3D Start Rotation are ideal, under Renderer select "Mesh" instead of "Billboard"
        //and apply the new material

        Pass
        {
            CGPROGRAM
            #pragma exclude_renderers gles //This had better compile on WebGL though, unity will complain if you remove this
            #pragma target 4.0
            #pragma vertex vertex_shader
            #pragma fragment fragment_shader
            #pragma multi_compile_instancing //This defines INSTANCING_ON which breaks positioning
            #pragma instancing_options procedural:vertInstancingSetup
            #define UNITY_PARTICLE_INSTANCE_DATA particle
            struct particle
            {
                float3x4 transform;
                uint color;
                float speed; //known as animFrame
            };
            #define UNITY_PARTICLE_INSTANCE_DATA_NO_ANIM_FRAME
            #include "UnityCG.cginc"
            #include "UnityStandardParticleInstancing.cginc" //Must be this way round
            //#include "Lighting.cginc"
            //#include "AutoLight.cginc" //Combine with LitVolume from PixelFire to get pre-traced Scene Lighting

            float4 _Color;
            sampler3D _Texture;
            uint _Steps;
            uint _Frame;
            float4 _DebugOrigin;
            float4 _DebugDirection;
            float4 _DebugScale;
            float4 _DebugView;
            float4 _DebugAlpha;

            struct supplicant //ideally use appdata_full
            {
                #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                float3 vertex : POSITION;
                float3 normal : NORMAL;
                float4 color : COLOR;
                float2 texcoord : TEXCOORD0; //As per default without custom vertex streams
                UNITY_VERTEX_INPUT_INSTANCE_ID
                #else
                float3 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                #endif
            };

            struct data
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                float3 blend : TEXCOORD20;
                float4 color : INSTANCED0;
                float3 unmodified : TEXCOORD21;
                #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                UNITY_PARTICLE_INSTANCE_DATA data : TEXCOORD1;
                #endif
            };

            data vertex_shader(supplicant input)
            {
                data output;
                output.unmodified = input.vertex;
                output.texcoord = input.texcoord;
                #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                UNITY_SETUP_INSTANCE_ID(input);
                vertInstancingColor(input.color);
                vertInstancingUVs(input.texcoord, output.texcoord, output.blend);
                output.data = unity_ParticleInstanceData[unity_InstanceID];
                output.color = input.color;
                #else
                output.color = _Color;
                output.blend = output.color;
                #endif
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.normal = UnityObjectToWorldNormal(input.normal);
                return output;
            }

            float4 fragment_shader(data input) : COLOR
            {
                float4 output;
                int tmp = _Steps; if (tmp < 0) { tmp = 0; }
                uint steps = tmp;
                const float stride = 2.0 / steps;

                float3 input_vertex = input.unmodified;
                float3 correction_factor = float3(0.0, 0.0, 0.0);
                #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                correction_factor = float3(input.data.transform[0].w * _DebugView.x * _DebugView.w,
                                           input.data.transform[1].w * _DebugView.y * _DebugView.w,
                                           input.data.transform[2].w * _DebugView.z * _DebugView.w);
                #else
                //correction_factor = float3(0.0, 0.0, 0.0); //This is correct...
                #endif
                
                float3 origin = input_vertex + float3(0.5, 0.5, 0.5) + _DebugOrigin;
                float3 direction = ObjSpaceViewDir(float4(input_vertex + correction_factor, 1.0)) * _DebugDirection;

                origin += direction * stride;

                for (uint i = 0; i < steps; ++i)
                {
                    float3 position = origin + direction * (i * stride);
                    if (position.x < 0.0
                    ||  position.x > 1.0
                    ||  position.y < 0.0
                    ||  position.y > 1.0
                    ||  position.z < 0.0
                    ||  position.z > 1.0) { break; } //should be continue or flag for compatibility on some systems

                    float4 source = tex3Dlod(_Texture, float4(position.x, position.y, position.z, _Frame));
                    output.rgb = (source.rgb * _DebugAlpha.x) + (1.0 - (source.a * _DebugAlpha.z)) * (output.rgb);
                    output.a = (source.a * _DebugAlpha.y) + (1.0 - (source.a * _DebugAlpha.w)) * output.a;
                }
                #if defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                return output;
                //return float4(input.unmodified.z * 1.0, 0.0, 0.0, 0.5);
                //return float4(direction.xyz, 0.5);
                #else
                return output;
                //return float4(input.unmodified.z * 1.0, 0.0, 0.0, 0.5);
                //return float4(direction.xyz, 0.5);
                #endif
            }
            ENDCG
        }
    }
}
