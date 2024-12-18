﻿Shader "Custom/SS_Rim"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Rim("Rim Effect", Range(-1,1)) = 0.25
    }
    SubShader
    {
        Tags { "Queue"= "Transparent"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert alpha:fade nolighting

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 viewDir;
        };

        fixed4 _Color;
        float _Rim;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = _Color;
            o.Albedo = c.rgb;
            float border = 1.0f - abs(dot(IN.viewDir, IN.worldNormal));
            float alpha = border *(1.0f - _Rim) + _Rim;
            o.Alpha = saturate(c.a*alpha);
            //o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
