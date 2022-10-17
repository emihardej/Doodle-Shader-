Shader "Unlit/Doodle_Outlined"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)

        _FrameTime("Doodle Frame Time", Range(0, 2)) = 0.2
		//_FrameCount("Doodle Frame Count", Int) = 24
		_OffsetScale("Doodle Noise Scale", Range(0,20)) = 1
        _OutlineColor ("Outline Color", Color) = (0,0,0,1)
        _Outline("Outline Weight", Range(0,1)) = 0.03
        _OutlineFrameTime("Outline Frame Time", Range(0,2)) = 0.2
        _OutlineOffsetScale("Outline Offset Scale", Range(0,20)) = 1
    }
    SubShader
    {
        Pass
        {
            Cull front
            ZWrite Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            float random (float2 uv)
            {
                return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
            }

            inline float snap (float x, float snap)
            {
                return snap * round(x / snap);
            }

            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : POSITION;
                float4 color : COLOR;
            };

            float _OutlineFrameTime;
            float _OutlineOffsetScale;
            uniform float _Outline;
            uniform float4 _OutlineColor;
            
            v2f vert(appdata v) {
                v2f o;                
                float time = snap(_Time.y, _OutlineFrameTime);
                float2 noise = random(v.vertex.xyz + float3(time, 0.0, 0.0)).x * _OutlineOffsetScale;
                v.vertex.xy += noise;
                o.pos = UnityObjectToClipPos(v.vertex);
                //o.color = v.color;
                float3 norm   = mul ((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                float2 offset = TransformViewToProjection(norm.xy);
            
                o.pos.xy += (offset * o.pos.z * _Outline);
                o.color = _OutlineColor;

                return o;
            }
            half4 frag(v2f i) :COLOR { return i.color; }
            ENDCG
            }

        Pass
        {
           // Tags { "RenderType"="Opaque" "Queue"="Geometry"}
            Tags { "RenderType"="Transparent" "Queue"="Transparent" }
		    Blend SrcAlpha OneMinusSrcAlpha
		    ZWrite off
            Cull back
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _FrameTime;
            float _OffsetScale;
            
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

                        float random (float2 uv)
            {
                return frac(sin(dot(uv,float2(12.9898,78.233)))*43758.5453123);
            }

            inline float snap (float x, float snap)
            {
                return snap * round(x / snap);
            }

            v2f vert (appdata v)
            {
                v2f o;
                // Add displacement code
                //v.vertex.x += 1;
                float time = snap(_Time.y, _FrameTime);
                float2 noise = random(v.vertex.xyz + float3(time, 0.0, 0.0)).x * _OffsetScale;
                //v.vertex.xyz += sin(_Time.y * _FrameTime + v.vertex.y * _OffsetScale);
                v.vertex.xy += noise;
                o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv)*_Color;
                return col;
            }
            ENDCG
        }
       

    }
}