Shader "Custom/SS_lerp"
{
    Properties
    {
        _MainTex ("Tex1", 2D) = "white" {}
		_MainTex2 ("Tex2", 2D) = "white" {}
		_lerp ( "Lerp", range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        //#pragma target 3.0

        sampler2D _MainTex;
		sampler2D _MainTex2;
		float _lerp;

        struct Input
        {
            float2 uv_MainTex;
			float2 uv_MainTex2;
        };
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			fixed4 d = tex2D(_MainTex2, IN.uv_MainTex2);

            fixed4 final = lerp(c,d,1-c.a);
            o.Albedo = final.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}