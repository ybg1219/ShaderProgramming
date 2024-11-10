Shader "Custom/SS_Hologram"
{
    Properties
    {
        _BumpMap("Normal", 2D) = "bump" {}
		_NumStriples("NumberStriples", Range(1, 10)) = 3
        _StriplesAlpha("StriplesAlpha", Range(0.1, 1.0)) = 0.1
        _HologramColor("HologramColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert noambient alpha:fade

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        
        int _NumStriples;
        float _StriplesAlpha;
        float4 _HologramColor;
        sampler2D _BumpMap;

        struct Input
        {
            float3 viewDir; // unity3d에서 받아온 3차원 벡터
			float3 worldPos;
            float2 uv_BumpMap;
        };
		
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf(Input IN, inout SurfaceOutput o) {
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
            float rim = saturate(dot(o.Normal, IN.viewDir));
            rim = saturate(pow(1 - rim, 3) + pow(frac(IN.worldPos.g * _NumStriples - _Time.y), 5)*_StriplesAlpha);
            //g = worldPos y 값의 소수점만 남겨서 1에 가까이되는 부분은 하얗게 나타나도록, pow로 선명한 흰 색의 범위
            //*striples로 한 칸에 줄무늬 n개를 원하면 n만큼 곱해서 반복되도록.
            //-Time.y 위로 올라가는 무늬
            //alpha 값 곱해줘서 색 변경.
            o.Emission = _HologramColor.rgb;
            o.Alpha = rim;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
