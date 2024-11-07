Shader "Custom/SS_pow"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1) 
        _AmbientColor("Ambient Color", Color) = (1,1,1,1)
        _MySliderValue("This is a Slider", Range(0,10)) = 2.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
        };
        float4 _AmbientColor;
        float _MySliderValue;

        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
	        fixed4 c = pow((_Color + _AmbientColor), _MySliderValue);
	        o.Albedo = c.rgb;
	        o.Alpha = c.a;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
