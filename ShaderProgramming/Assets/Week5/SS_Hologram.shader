Shader "Custom/SS_Hologram"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
		_BumpTex("Normal", 2D) = "bump" {}

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert noambient alpha : fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		sampler2D _BumpTex;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 viewDir; // unity3d에서 받아온 3차원 벡터
			float3 worldPos;

        };
		
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpMap));
			float rim = saturate(dot(o.Normal, IN.viewDir));
			rim = pow(1 - rim,3); // 급격한 변화
			//rim = 1;
			//o.Emission = IN.worldPos.rgb; //world좌표 값을 color 값으로 사용, 이동시키면 색이 변함.
			o.Emission = _Color.rgb + pow(frac(IN.worldPos.g*10 - _Time.y),20)*_Color.rgb; // 좌표 *10 하면 촘촘해짐, 시간 빼면 위로 올라감.
            o.Alpha = rim*abs(sin(_Time.y*3)); // 깜빡거리도록, 절댓값 씌워서
        }
        ENDCG
    }
    FallBack "Diffuse"
}
