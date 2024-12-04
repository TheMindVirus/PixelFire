Shader "Standard/Normal"
{
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "LightMode" = "Always" }
        Blend SrcAlpha DstAlpha
        Cull Front ZWrite Off ZTest LEqual //Not Equal

        CGPROGRAM
        #pragma surface surface Standard fullforwardshadows alpha:blend vertex:vertex

        struct Input { fixed3 normal; };

        void vertex(inout appdata_full input, out Input output)
        {
            output.normal = input.normal; //UnityObjectToWorldNormal(input.vertex);
        }

        void surface(Input input, inout SurfaceOutputStandard output)
        {
            output.Albedo = fixed3(0.0, 0.0, 0.0);
            output.Alpha = 0.5;
            output.Metallic = 1.0;
            output.Smoothness = 1.0;

            //output.Normal = input.normal;
            output.Emission = 0.0; //output.Albedo;
            output.Occlusion = 0.5;
        }
        ENDCG

        Blend SrcAlpha DstAlpha
        Cull Back ZWrite Off ZTest LEqual //Not Equal

        CGPROGRAM
        #pragma surface surface Standard fullforwardshadows alpha:blend vertex:vertex

        struct Input { fixed3 normal; };

        void vertex(inout appdata_full input, out Input output)
        {
            output.normal = input.normal; //UnityObjectToWorldNormal(input.vertex);
        }

        void surface(Input input, inout SurfaceOutputStandard output)
        {
            output.Albedo = fixed3(0.0, 0.0, 0.0);
            output.Alpha = 0.5;
            output.Metallic = 1.0;
            output.Smoothness = 1.0;

            //output.Normal = input.normal;
            output.Emission = 0.0; //output.Albedo;
            output.Occlusion = 1.0;
        }
        ENDCG
    }
}
