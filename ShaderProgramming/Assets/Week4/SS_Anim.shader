Shader "Custom/SS_Anim"
{
	Properties
	{
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_MainTex2("Albedo (RGB)", 2D) = "black" {} // 기본값 블랙

		//_Velocity("Velocity", Range(0,1)) = 0.0
	}
		SubShader
		{
			Tags { "RenderType" = "Transparent" "Queue"="Transparent" } 
			// 렌더타입 변경
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard alpha:fade // alpha 값 적용

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _MainTex2;

			struct Input
			{
				float2 uv_MainTex;
				float2 uv_MainTex2;

			};

			fixed4 _Color;

			// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
			// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
			// #pragma instancing_options assumeuniformscaling
			UNITY_INSTANCING_BUFFER_START(Props)
				// put more per-instance properties here
			UNITY_INSTANCING_BUFFER_END(Props)

			void surf(Input IN, inout SurfaceOutputStandard o)
			{
				// 가장자리 흐려짐 왜 .. ? 복습 필요
				fixed4 d = tex2D(_MainTex2, float2(IN.uv_MainTex2.x, IN.uv_MainTex2.y - _Time.y));
				//알파값이 있으면 그만큼 더해져서 당겨와짐.

				float2 fire_uv = IN.uv_MainTex + d.r; //배경 제거
				fixed4 c = tex2D(_MainTex,float2(fire_uv.x-0.1 , fire_uv.y - 0.1)); // 살짝 있는 심 제거
				o.Emission = c.rgb;
				o.Alpha = c.a;// 1이 마지막자리라 값이 더 하면 변경됨
			}
			ENDCG
		}
			FallBack "Diffuse"
}