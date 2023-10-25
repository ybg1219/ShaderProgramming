Shader "Custom/SS_BlinnPhong"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}
        _SpecularColor("Specular Color", Color) = (1,1,1,1)
        _SpecPower("Specular Power",Range(0,100)) = 10.0
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 200

            CGPROGRAM
            // Physically based Standard lighting model, and enable shadows on all light types
            #pragma surface surf BlinnPhong

            // Use shader model 3.0 target, to get nicer looking lighting
            #pragma target 3.0

            sampler2D _MainTex;

            struct Input
            {
                float2 uv_MainTex;
            };

            fixed4 _Color;
            float _SpecPower;
            fixed4 _SpecularColor;

            // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
            // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
            // #pragma instancing_options assumeuniformscaling
            UNITY_INSTANCING_BUFFER_START(Props)
                // put more per-instance properties here
            UNITY_INSTANCING_BUFFER_END(Props)

            void surf(Input IN, inout SurfaceOutput o)
            {
                // Albedo comes from a texture tinted by color
                fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
                o.Albedo = c.rgb;
                o.Alpha = c.a;
            }
            float4 LightingBlinnPhong(SurfaceOutput s,fixed3 lightDir, float3 viewDir, fixed atten)
            {
                float NDotL = dot(s.Normal, lightDir);
                float3 rVec = normalize(2 * s.Normal * NDotL - lightDir);

                float spec = pow(max(0, dot(rVec, viewDir)), 3);
                float3 finalSpec = spec * _SpecularColor.rgb;

                fixed4 c;
                c.rgb = (s.Albedo * _LightColor0.rgb * max(0, NDotL) * atten) + (_LightColor0.rgb * finalSpec);
                c.a = s.Alpha;
                return c;
            }
            ENDCG
        }
            FallBack "Diffuse"
}
