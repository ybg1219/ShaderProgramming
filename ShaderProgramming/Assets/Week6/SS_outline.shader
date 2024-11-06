﻿Shader "Custom/SS_outline"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Outline("Outline thickness", float) = 0.003
        _OutlineColor("Outline Color", color) = (0,0,0,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        // 1st pass for outline
        Cull Front // Render only the back faces to create the outline
        CGPROGRAM
        #pragma surface surf OutlineShader vertex:vert noshadow noambient
        #pragma target 3.0

        sampler2D _MainTex;
        float4 _OutlineColor;
        float _Outline;

        void vert(inout appdata_full v) {
            v.vertex.xyz += v.normal.xyz * _Outline * abs(sin(_Time.y));
        }

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 mainTexColor = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = mainTexColor.rgb * _OutlineColor.rgb;
            o.Alpha = mainTexColor.a;
        }

        float4 LightingOutlineShader(SurfaceOutput s, float3 lightDir, float atten) {
            return float4(s.Albedo, s.Alpha);
        }
        ENDCG

        //path 2
        cull back
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Toon noambient

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };
        fixed4 _ColorVar;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) ;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }float4 LightingToon(SurfaceOutput s, float3 lightDir, float atten) {
            
            return float4(1,1,1,1);
        }

        ENDCG
    }
    FallBack "Diffuse"
}
