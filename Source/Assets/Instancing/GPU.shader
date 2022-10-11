Shader "Instanced/GPU"
{
    Properties
    {
        _Color("Colour", Color) = (1.0, 1.0, 1.0, 1.0)
        _Texture("Texture", 3D) = "white" {}
        _Steps("Steps", Range(0, 512)) = 512
    }
    SubShader
    {
        Tags{ "Queue" = "Transparent" "RenderType" = "Opaque" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Front

        Pass
        {
            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vertex
            #pragma fragment fragment
            #define UNITY_ENABLE_INSTANCING
            //#define INSTANCING_ON
            #include "UnityInstancing.cginc"
            #include "UnityCG.cginc"
            #pragma multi_compile_instancing
            #pragma instancing_options procedural:vertInstancingSetup

            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // #pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)

            uint _Steps;
            float4 _Color;
            sampler3D _Texture;
            float4 _Texture_ST;

            struct supplicant
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                uint instanceID : SV_InstanceID;
            };

            struct data
            {
                float4 vertex : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                uint instanceID : SV_InstanceID;
            };

            data vertex(supplicant input)
            {
                data output;
                UNITY_SETUP_INSTANCE_ID(input);
                output.vertex = UnityObjectToClipPos(input.vertex); //This gets modified
                //output.vertex = input.vertex; //This is just broken, use Geometry Shader instead
                output.texcoord = input.texcoord;
                output.instanceID = input.instanceID;
                return output;
            }

            fixed4 fragment(data input) : SV_Target
            {
                //float4 output = _Texture_ST;
                float output = _Color;
                return output;
            }
            ENDCG
        }
    }
}