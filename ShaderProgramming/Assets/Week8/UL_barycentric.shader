Shader "Unlit/UL_barycentric"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _WireframeColor("Wire Color",Color) = (1,1,1,1)
        _Color("Color",Color) = (1,1,1,1)
    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma target 4.0 // geometry shader 4.0 이상부터 작동.
            #pragma vertex vert
            #pragma geometry geom // geometry shader는 geom으로 부르겠다.
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            { // 사용자가 입력으로 넣은 데이터
                float4 vertex : POSITION; // = pos
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            struct v2g {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct g2f {
                float4 pos: POSITION;
                float2 uv : TEXCOORD0;
                float3 dist : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _WireframeColor;
            float4 _Color;
            //v2f vert (appdata v)
            //{
            //    v2f o;
            //    o.vertex = UnityObjectToClipPos(v.vertex); // local - > view -> clip화면에 보이는 포지션으로 바꿔줌.
            //    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            //    UNITY_TRANSFER_FOG(o,o.vertex);
            //    return o;
            //}
            v2g vert(appdata input)
            {
                v2g output;
                output.pos = UnityObjectToClipPos(input.vertex); // vertex 인지 pos 인지 확인할 것.
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                return output;
            }
            float3 VertexDist(float4 v0, float4 v1, float4 v2) {
                float dist0 = length(v0);
                float dist1 = length(v1);
                float dist2 = length(v2);
                return float3 (dist0, dist1, dist2);
            }

            //편집할 버텍스넘버 개수 설정.
            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                //geometry 쉐이더
                g2f output;
                float3 dist = VertexDist(input[0].pos, input[1].pos, input[2].pos);

                float2 winScale = float2(_ScreenParams.x / 2.0, _ScreenParams.y / 2.0);
                // frag pos.
                float2 p0 = winScale * input[0].pos.xy / input[0].pos.w; // winscale 윈도우 화면 크기
                float2 p1 = winScale * input[1].pos.xy / input[1].pos.w;
                float2 p2 = winScale * input[2].pos.xy / input[2].pos.w;
                // barycentric pos.
                float2 v0 = p2 - p1;
                float2 v1 = p2 - p0;
                float2 v2 = p1 - p0;

                //triangles area
                float area = abs(v1.x * v2.y - v1.y * v2.x); // 2차원 공간에서 삼각형의 너비

                for (int i = 0; i < 3; i++)
                {
                    output.pos = input[i].pos;
                    output.uv = input[i].uv;
                    output.dist = float3(0, 0, 0); // dist 초기화
                    if (i == 0)
                        output.dist = float3(area / length(v0), 0, 0); // 무게중심에서 x값 멀어지면 빨간색 값이 증가.
                    else if (i == 1)
                        output.dist = float3(0, area / length(v1), 0);
                    else if (i == 2)
                        output.dist = float3(0, 0 , area / length(v2));
                    triStream.Append(output);// 각 경우마다 한번씩 append
                }
            }
            float WireColor(float3 dist, float thickness) {
                float d = min(dist.x, min(dist.y, dist.z));
                d = 1.0f - smoothstep(0, thickness, d); // 시그모이드 형태의 함수
                return d;
            }

            //frament 쉐이더 위에서 작업한 g2f 가져오면 똑같이 나옴.
            fixed4 frag(g2f input) : SV_Target // 원래 v2f vertex에서 바로 넘겼는데 중간에 과정이 하나 더 생김.
            {
                // wire 그리는 코드
                float4 finalColor = 1;
                float d = WireColor(input.dist, 1.5); // 0.05 안에 있는 값들은 색이 1, 아닌 값은 0근처로 나오게 하는 듯
                finalColor.rgb = float3(d, d, d);
                float w = exp2( -4.0 * d * d);
                return lerp(_WireframeColor, _Color, w);
                return finalColor;
            }
            ENDCG
        }
    }
}