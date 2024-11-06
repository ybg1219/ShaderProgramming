Shader "Unlit/UL_Wireframe"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                output.pos = UnityObjectToClipPos(input.vertex); // appdata vertex 인지 pos 인지 확인할 것.
                output.uv = TRANSFORM_TEX(input.uv, _MainTex);
                return output;
            }
            float3 VertexDist(float4 v0, float4 v1, float4 v2) {
                // 길이 -> 양수 반환
                float dist0 = length(v0);
                float dist1 = length(v1);
                float dist2 = length(v2);
                return float3 (dist0, dist1, dist2);
            }

            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream)
            {
                g2f output;
                float3 dist = VertexDist(input[0].pos, input[1].pos, input[2].pos); // pos to distance

                for (int i = 0; i < 3; i++)
                {
                    output.pos = input[i].pos;
                    output.uv = input[i].uv;
                    output.dist = float3(0, 0, 0); // dist 초기화

                    if (i == 0)// 스크롤 정도 w에 따라 x,y,z 스케일링돼서 색이 변하는 것.
                        output.dist=  float3(1,0,0); // float3(dist.x,0,0);
                    else if (i == 1)
                        output.dist =  float3(0,1, 0); // float3(0,dist.y,0);
                    else if (i == 2)
                        output.dist =  float3(0,0,1); //float3(0,0,dist.z);

                    triStream.Append(output);// 각 경우마다 한번씩 append
                }
                /*
                // geom에서 파라미터로 받아온 tristream
                g2f output;
                output.pos= input[0].pos;
                output.uv = input[0].uv;
                tristream.Append[output];

                output.pos= input[1].pos;
                output.uv = input[1].uv;
                tristream.Append[output];

                output.pos= input[2].pos;
                output.uv = input[2].uv;
                tristream.Append[output];*/
            }

            


            fixed4 frag(g2f input) : SV_Target // 원래 v2f vertex에서 바로 넘겼는데 중간에 과정이 하나 더 생김.
            { 
                // float3 finalColor = 1; 
                float3 finalColor = input.dist;
                return float4 (finalColor,1);
            }
            ENDCG
        }
    }
}
