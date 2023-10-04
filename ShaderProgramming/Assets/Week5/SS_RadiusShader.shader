Shader "Custom/SS_RadiusShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Center("Center",Vector) = (200,0,200,0)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Radius ("Radius", Float) = 100
        _RadiusColor ("RadiusColor", Color) = (1,0,0,1)
        _RadiusWidth("Radius Width",Float) = 10
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
        float3 _Center;
        float _Radius;
        fixed4 _RadiusColor;
        float _RadiusWidth;

        struct Input
        {
            float2 uv_MainTex;
			float3 worldPos; // float2 로 했더니 선이 나타났다. 같은 거리가 구로 표시되도록 하려면 3차원 구.
        };
        
        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Alpha = c.a;

			float d = distance(_Center, IN.worldPos);//center에서 worldPos x,y,z 각 위치에서 거리를 d 에 저장
			if ((d > _Radius) && (d < _Radius + _RadiusWidth)) {
				o.Albedo = _RadiusColor;
			}
			else {
				o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
			}
        }
        ENDCG
    }
    FallBack "Diffuse"
}
