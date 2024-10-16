Shader "Custom/SS_terrain"
{
    Properties
    {
        _MainTint ("_MainTint", Color) = (1,1,1,1)
        _ColorA ("_ColorA", Color) = (1,1,1,1)
        _ColorB ("_ColorB", Color) = (1,1,1,1)
        _RTexture ("_RTexture", 2D) = "white" {}
        _GTexture ("_GTexture", 2D) = "white" {}
        _BTexture ("_BTexture", 2D) = "white" {}
        _ATexture ("_ATexture", 2D) = "white" {}
        _BlendTex ("_BlendTex", 2D) = "white" {}
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
            
            float2 uv_RTexture;
            float2 uv_GTexture;
            float2 uv_BTexture;
            float2 uv_ATexture;
            float2 uv_BlendTex;

        };

        float4 _MainTint;
        float4 _ColorA ;
        float4 _ColorB;
        sampler2D _RTexture;
        sampler2D _GTexture;
        sampler2D _BTexture;
        sampler2D _ATexture;
        sampler2D _BlendTex;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float4 blendData = tex2D(_BlendTex, IN.uv_BlendTex);
            float4 rTexData = tex2D(_RTexture, IN.uv_RTexture);
            float4 gTexData = tex2D(_GTexture, IN.uv_GTexture);    
            float4 bTexData = tex2D(_BTexture, IN.uv_BTexture);
            float4 aTexData = tex2D(_ATexture, IN.uv_ATexture);

            float4 finalColor;
            finalColor = lerp(rTexData, gTexData, blendData.g);
            finalColor = lerp(blendData, bTexData, blendData.b);
            finalColor = lerp(blendData, aTexData, blendData.a);
            finalColor.a = 1.0f;

            float4 terrainLayers = lerp(_ColorA, _ColorB, blendData.r);
            finalColor *= terrainLayers;
            finalColor = saturate(finalColor);
            o.Albedo = finalColor.rgb * _MainTint.rgb;
            o.Alpha = finalColor.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
