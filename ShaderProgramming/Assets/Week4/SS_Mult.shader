Shader "Custom/SS_Mult"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_MainTex2("Albedo (RGB)", 2D) = "white" {}
		_MainTex3("Albedo (RGB)", 2D) = "white" {}
		_MainTex4("Albedo (RGB)", 2D) = "white" {}

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

		sampler2D _MainTex;
		sampler2D _MainTex2;
		sampler2D _MainTex3;
		sampler2D _MainTex4;

		struct Input
		{
			float2 uv_MainTex; // 텍스처 사이즈 각각 동일
			float4 color:COLOR;
		};

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf(Input IN, inout SurfaceOutputStandard o)
		{

			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			fixed4 d = tex2D(_MainTex2, IN.uv_MainTex);
			fixed4 e = tex2D(_MainTex3, IN.uv_MainTex);
			fixed4 f = tex2D(_MainTex4, IN.uv_MainTex);

			//o.Emission = IN.color.rgb;
			//o.Albedo = c.rgb + IN.color.rgb;
			//o.Albedo = c.rgb * IN.color.rgb;

			o.Albedo = lerp(c.rgb, d.rgb, IN.color.r); // 유브이의 컬러.r값에 lerp 저장
			o.Albedo = lerp(o.Albedo, e.rgb, IN.color.g);
			o.Albedo = lerp(o.Albedo, f.rgb, IN.color.b);

			// 값이 있는 부분 = 흰색됨. 밝아짐 // 곱하기만 하면 0인 부분 어둡게 나타나고 더하기ㅡ>
			o.Alpha = c.a;
		}
			ENDCG
	}
		FallBack "Diffuse"
}