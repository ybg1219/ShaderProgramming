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
        #pragma surface surf Standard fullforwardshadows

        #pragma target 3.0

        struct Input
        {
            float2 uv_Main;  // 여러 텍스처에서 같은 UV 좌표 사용
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

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float4 blendData = tex2D(_BlendTex, IN.uv_BlendTex);
            float4 rTexData = tex2D(_RTexture, IN.uv_Main);   // 공유된 UV 사용
            float4 gTexData = tex2D(_GTexture, IN.uv_Main);   // 공유된 UV 사용
            float4 bTexData = tex2D(_BTexture, IN.uv_Main);   // 공유된 UV 사용
            float4 aTexData = tex2D(_ATexture, IN.uv_Main);   // 공유된 UV 사용

            float4 finalColor;
            finalColor = lerp(rTexData, gTexData, blendData.g);
            finalColor = lerp(finalColor, bTexData, blendData.b);
            finalColor = lerp(finalColor, aTexData, blendData.a);
            finalColor.a = 1.0;

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
