Shader "Custom/SS_BlinnPhongPrac"
{
    Properties
    {
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		GlossMap("Gloss Map",2D) = "black" {}
		_BumpMap("Normal",2D) = "bump" {}
		_SpecCol("SpecularColor",Color) = (1,1,1,1)
		_fakeSpecCol("Fake SpecularColor",Color) = (1,1,1,1)
		_SpecPower("Spec Power",Range(1,100))=10
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
		sampler2D _GlossMap;


		struct Input
		{
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float2 uv_GlossMap;
			float3 viewDir;

		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _SpecCol;
		fixed4 _fakeSpecCol;
		float _SpecPower;

		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf(Input IN, inout SurfaceOutput o)
		{
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			fixed4 m = tex2D(_GlossMap, IN.uv_GlossMap);
			o.Gloss = m.a;
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		float4 LightingTest(SurfaceOutput s,  float3 lightDir, float3 viewDir, float atten) {
			//인자 선언 순서 중요

			//Lambert Term
			float3 DiffColor;
			float nDotL = saturate(dot(s.Normal, lightDir));
			
			DiffColor = nDotL * s.Albedo * _LightColor0 * atten;

			//Specular Term
			float3 halfVec = normalize(lightDir + viewDir);
			float spec = saturate(dot(halfVec, s.Normal));
			spec = pow(spec, _SpecPower);
			float3 specColor= spec * _SpecCol.rgb* s.Gloss;

			//RimTerm
			float3 rimColor;
			float rim = abs(dot(viewDir, s.Normal));
			float invRim = 1.0 - rim;
			rimColor = pow(invRim, 6) * float3(0.5, 0.5, 0.5);

			//fake specular Term
			float3 fakeSpec;
			fakeSpec = pow(rim, 50) * float3(0.8, 0.8, 0.8)*s.Gloss*_fakeSpecCol;

			//Final Term
			float4 final;

			final.rgb = DiffColor.rgb + specColor.rgb + rimColor +fakeSpec;
			final.a = s.Alpha;

			//return float4(halfVec,1);// 시점와 뷰벡터의 합이 계산 잘 되었는지 확인.
			return final;
		}
        ENDCG
    }
    FallBack "Diffuse"
}
