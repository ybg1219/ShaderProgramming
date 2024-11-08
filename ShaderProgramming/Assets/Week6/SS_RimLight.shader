Shader "Custom/SS_RimLight"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "black" {}
		_BumpTex("Normal", 2D) = "bump" {}
		_RimPower("RimPower",Range(1,10)) = 3
		_RimColor("RimColor",Color) =(1,1,1,1)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert noambient

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
		sampler2D _BumpTex;
		float _RimPower;
		float4 _RimColor;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 viewDir; // unity3d에서 받아온 3차원 벡터
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
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) ;
			o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpMap));
			o.Albedo = c.rgb;
			float rim = saturate(dot(o.Normal, IN.viewDir));
			o.Emission = pow(1 - rim,_RimPower)* _RimColor.rgb; // 급격한 변화
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
