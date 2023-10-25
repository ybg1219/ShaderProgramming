Shader "Custom/SS_BlinnPhongPrac"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		_BumpMap("Normal",2D) = "bump" {}
		_SpecCol("SpecularColor",Color) = (1,1,1,1)
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
			float3 viewDir;

		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _SpecCol;
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf(Input IN, inout SurfaceOutput o)
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		float4 LightingTest(SurfaceOutput s, float3 viewDir, float3 lightDir, float atten) {
			//Lambert Term
			float3 DiffColor;
			float nDotL = saturate(dot(s.Normal, lightDir));
			
			DiffColor = nDotL * s.Albedo * _LightColor0 * atten;

			//Specular Term
			float3 halfVec = normalize(lightDir + viewDir);
			float spec = saturate(dot(halfVec, s.Normal));
			spec = pow(spec, 100);
			float3 specColor= spec * _SpecCol.rgb;
			//RimTerm
			float3 rimColor;
			float rim = abs(dot(viewDir, s.Normal));
			float invRim = 1.0 - rim;
			rimColor = pow(invRim, 6) * float3(0.5, 0.5, 0.5);

			//Final Term
			float4 final;

			final.rgb = DiffColor.rgb + specColor.rgb +rimColor;
			final.a = s.Alpha;

			//return float4(halfVec,1);// 시점와 뷰벡터의 합이 계산 잘 되었는지
			return spec;
		}
        ENDCG
    }
    FallBack "Diffuse"
}
