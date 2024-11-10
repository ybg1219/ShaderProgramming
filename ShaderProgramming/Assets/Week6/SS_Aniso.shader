Shader "Custom/SS_Aniso"
{
    Properties
    {
    _MainTint("Diffuse Tint", Color) = (1,1,1,1)
    _MainTex("Base (RGB)", 2D) = "white" {}
    _SpecularColor("Specular Color", Color) = (1,1,1,1)
    _Specular("Specular Amount", Range(0,1)) = 0.5
    _SpecPower("Specular Power", Range(0,1)) = 0.5
    _AnisoDir("Anisotropic Direction", 2D) = ""{}
    _AnisoOffset("Anisotropic Offset", Range(-1, 1)) = -0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Anisotrophic

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _AnisoDir;
        float4 _MainTint;
        float4 _SpecularColor;
        float _AnisoOffset;
        float _Specular;
        float _SpecPower;

        struct SurfaceAnisoOutput {
            fixed3 Albedo;
            fixed3 Normal;
            fixed3 Emission;
            fixed3 AnisoDirection;
            half Specular;
            fixed Gloss;
            fixed Alpha;
        };
        struct Input
        {
            float2 uv_MainTex;
            float2 uv_AnisoDir;
        };

        half _Glossiness;
        half _Metallic;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceAnisoOutput o)
        {
            half4 c = tex2D(_MainTex, IN.uv_MainTex) * _MainTint;
            float3 anisoTex = UnpackNormal(tex2D (_AnisoDir, IN.uv_AnisoDir));
            o.AnisoDirection = anisoTex;
            o.Specular = _Specular;
            o.Gloss = _SpecPower;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        fixed4 LightingAnisotrophic(SurfaceAnisoOutput s, fixed3 lightDir, half3 viewDir, fixed atten) {
            viewDir = normalize(viewDir);
            lightDir = normalize(lightDir);

            //Diffuse d = N dot L
            half NdotL = saturate(dot(s.Normal, lightDir));

            //HalfVector
            float3 halfVector = normalize(viewDir + lightDir);

            // Anisotropic:
            // HdotA is 0 when perpendicular to the Anisotropic normal map, 1 when parallel.
            // -> 수직인 부분 쪽으로 갈 수록 cos값 감소.
            float HdotA = dot((s.Normal + s.AnisoDirection), halfVector);

            // modify the value with sin() so that we get a darker
            // middle highlight and a ring effect based off of the halfVector
            // cos 값 + offset * 180
            float aniso = max(0.0f, sin(radians((HdotA + _AnisoOffset) * 180.0f)));

            // Specular:
            // scale the aniso value by taking it to a power of s.Gloss,
            // then globally decrease its strength by multiplying it by s.Specular
            float spec = saturate(pow(aniso, s.Gloss * 128) * s.Specular);

            // Final effect: I = D + S
            fixed4 c;
            c.rgb = (s.Albedo * _LightColor0.rgb * NdotL) + (_LightColor0.rgb * _SpecularColor.rgb * spec) * atten;
            c.a = s.Alpha;

            return c;

        }
        ENDCG
    }
    FallBack "Diffuse"
}
