﻿Shader "Custom/SS_Normal"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal",2D) = "bump" {}
		 _NormalMapIntensity("Normal intensity", Range(0, 3)) = 1
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Test noambient

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;


		struct Input
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};

		float _NormalMapIntensity;
		fixed4 _Color;

		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf(Input IN, inout SurfaceOutput o)
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

			o.Albedo = c.rgb;
			o.Alpha = c.a;
			float3 n = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
			n.x *= _NormalMapIntensity;
			n.y *= _NormalMapIntensity;
			o.Normal = normalize(n.rgb);
		}
		float4 LightingTest(SurfaceOutput s, float3 lightDir, float atten) {
			float nDotL = dot(s.Normal, lightDir)*0.5 + 0.5;
			nDotL = pow(nDotL, 2);
			float4 final;
			final.rgb = nDotL * s.Albedo*_LightColor0*atten;
			final.a = s.Alpha;
			return final;
		}
        ENDCG
    }
    FallBack "Diffuse"
}
