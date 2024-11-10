Shader "Custom/SS_Fresnel"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _ColorVar("Color Steps",float ) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Toon noshadow 

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        struct Input
        {
            float2 uv_MainTex;
            float4 color : COLOR;
        };

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Albedo comes from a texture tinted by color
           
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        } float4 LightingToon(SurfaceOutput s, float3 lightDir, float3 viewDir, float atten) {
            float NDotL = dot(s.Normal, lightDir) * 0.5 + 0.5;
			NDotL = NDotL * 5.0;
			NDotL = ceil(NDotL) / 5;

            float rim = abs(dot(s.Normal, viewDir));
            rim = rim > 0.3 ? 1.0:-1.0;

            float4 final;
            final.rgb =s.Albedo*NDotL*_LightColor0.rgb*rim;
            final.a = s.Alpha;
            return final;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
