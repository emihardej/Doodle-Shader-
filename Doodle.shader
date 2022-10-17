Shader "Unlit/Doodle"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}

        // Doodle properties
		//_MaxOffset("Doodle Max Offset", vector) = (0.005, 0.005, 0, 0)
		_FrameTime("Doodle Frame Time", Range(0, 2)) = 0.2
		//_FrameCount("Doodle Frame Count", Int) = 24
		_OffsetScale("Doodle Noise Scale", Range(0,1)) = 1
    }
    SubShader
    {


        Pass
        {
            Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		    Blend SrcAlpha OneMinusSrcAlpha
		    ZWrite off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _FrameTime;
            float _OffsetScale;

            float random (float2 pos)
            {
                return frac(sin(dot(pos.xy,float2(12.9898,78.233)))*43758.5453123);
            }

            // inline float jit (float x, float jitter)
            // {
            //     return jitter * round(x / jitter);
            // }

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
            };

            

            v2f vert(appdata v)
            {
                v2f o;
                // Add displacement code
                //v.vertex.x += 1;
                //float time = jit(_Time.y, _FrameTime);
                float time =  _FrameTime * round(_Time.y / _FrameTime);
                float2 rand = random(v.vertex.xyz + float3(time, 0.0, 0.0)).x * _OffsetScale;
                //v.vertex.xyz += sin(_Time.y * _FrameTime + v.vertex.y * _OffsetScale);
                v.vertex.xy += rand;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = tex2D(_MainTex, i.uv )* _Color;
				return col;
            }
            ENDCG
        }
    }
}
