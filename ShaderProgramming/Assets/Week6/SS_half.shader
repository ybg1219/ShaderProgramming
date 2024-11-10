﻿Shader "Custom/SS_half"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Normal",2D) = "bump" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Test

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;

		struct Input
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};

		fixed4 _Color;

		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf(Input IN, inout SurfaceOutput o)
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		}
		float4 LightingTest(SurfaceOutput s, float3 lightDir, float atten) { // 꼭 Lighting 을 붙이기
			float nDotL = pow(dot(s.Normal, lightDir)*0.5+0.5, 2); // saturate하면 속눈썹튀는게 많이 줄어든다.
			float4 final;
			final.rgb = nDotL*s.Albedo*atten * _LightColor0;
			final.a = s.Alpha;
			return final;
		}
		ENDCG
	}
		FallBack "Diffuse"
}