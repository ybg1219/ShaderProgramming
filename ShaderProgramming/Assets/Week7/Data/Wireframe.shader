Shader "Unlit/Wireframe"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color("Wire Color", Color) = (1, 1, 1, 1)
		_WireframeColor("Wire Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
			#pragma target 4.0
            #pragma vertex vert
			#pragma geometry geom
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

			struct v2g {
				float4 pos:POSITION;
				float2 uv:TEXTCOORD0;
			};

			struct g2f {
				float4 pos:POSITION;
				float2 uv:TEXTCOORD0;
				float3 dist : TEXCOORD1;
			};

            sampler2D _MainTex;
            float4 _MainTex_ST;
			float4 _WireframeColor;
			float4 _Color;

            v2g vert (appdata v)
            {
                v2g o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

			float3 VertexDist(float4 v0, float4 v1, float4 v2) {
				float dist0 = length(v0);
				float dist1 = length(v1);
				float dist2 = length(v2);
				return float3(dist0, dist1, dist2);
			}

			[maxvertexcount(3)]
			void geom(triangle v2g input[3], inout TriangleStream<g2f> triStream) {
				g2f output;
				float3 dist = VertexDist(input[0].pos, input[1].pos, input[2].pos);
				float2 winScale = float2(_ScreenParams.x / 2.0, _ScreenParams.y / 2.0);
				// frag pos.
				float2 p0 = winScale * input[0].pos.xy / input[0].pos.w;
				float2 p1 = winScale * input[1].pos.xy / input[1].pos.w;
				float2 p2 = winScale * input[2].pos.xy / input[2].pos.w;
				// barycentric pos.
				float2 v0 = p2 - p1;
				float2 v1 = p2 - p0;
				float2 v2 = p1 - p0;
				//triangles area
				float area = abs(v1.x*v2.y - v1.y * v2.x);
				for (int i = 0; i < 3; i++) {
					output.pos = input[i].pos;
					output.uv = input[i].uv;
					if (i == 0) output.dist = float3(area / length(v0), 0, 0);
					else if (i == 1) output.dist = float3(0, area / length(v1), 0);
					else if (i == 2) output.dist = float3(0, 0, area / length(v2));
					triStream.Append(output);					
				}
			}

										
			float WireColor(float3 dist, float thickness) {
				float d = min(dist.x, min(dist.y, dist.z));
				d = 1.0f - smoothstep(0, thickness, d);
				return d;
			}

			float4 frag(g2f input) : SV_Target{
				float4 finalColor = 1;
				float d = WireColor(input.dist, 1.5);
				float w = exp2(-4.0 * d * d);
				return lerp(_WireframeColor, _Color, w);
			}


            ENDCG
        }
    }
}
