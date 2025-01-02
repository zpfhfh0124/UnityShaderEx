Shader "GT/CelLightingToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutlineColor("OutlineColor", Color) = (0,0,0,1)
        _OutlineThickness("OutlineThickness", Range(0, 0.1)) = 0.001
        
        [Header(FallOff)]
        _FallOffStepValue("FallOffStepValue", Range(0,1)) = 0.5
        [Header(Rim)]
        _RimColorIntensity("RimColorIntensity", float) = 1.0
        _RimOpacity("RimOpacity", Range(0,1)) = 1.0
    }
    
    // lighting
    
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 worldNormal : NORMAL;
            };

            sampler2D _MainTex;
            float _FallOffStepValue;

            float3 _RimColor;
            float _RimOpacity;
            float _RimColorIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // lighting
                float lighting = saturate(dot(i.worldNormal, _WorldSpaceLightPos0.xyz)); // 월드 노멀 백터와 디렉셔널 라이트의 내적을 0~1로 clamp
                float fallOff = 1.0 - step(lighting, _FallOffStepValue); // lighting이 _FallOffStepValue보다 크거나 같으면 1, 아니면 0
                
                float4 col = tex2D(_MainTex, i.uv);
                // RimColor
                col.rgb = lerp(col.rgb, lerp(col.rgb, col.rgb + col.rgb * _RimColor * _RimColorIntensity, _RimOpacity), fallOff);
                
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDHLSL
        }
    }
}
