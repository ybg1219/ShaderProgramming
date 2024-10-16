Shader "Custom/SS_Mapping"
{
    Properties
    {
        _Tint ("Tint", Color) = (0,1,0,1)
        _NormalTex("Normal", 2D) = "bump" {}
        _NormalIntensity("Normal Intensity", Range(0,3))=1
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _NormalTex;
        float4 _Tint;
        float _NormalIntensity;
        struct Input
        {
            float2 uv_NormalTex;
        };


        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = _Tint;
            float3 n = UnpackNormal(tex2D(_NormalTex, IN.uv_NormalTex));
            //n.x *= _NormalIntensity;
            //n.y *= _NormalIntensity;
            o.Normal = normalize(n.rgb);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
