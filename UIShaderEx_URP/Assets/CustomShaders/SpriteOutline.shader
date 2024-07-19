Shader "Custom/SpriteOutline"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        
        _AlphaCullOff ("Alpha Cull Off", Range(0,1)) = 0.5
        
        _Outline("Outline", Float) = 0
        _OutlineColor("Outline Color", Color) = (1,1,1,1)
        _OutlineSize("Outline Size", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RederPipeline"="UnivarsalPipeline"
            "RenderType"="Transparent"
            //"LightMode"="Outline"    
            "PreviewType"="Plane"
            "IgnoreProjector"="True"
        }
        
        Cull Off
        Blend One OneMinusSrcAlpha // (색1 * 1) + (색2 * (1 - 색1 알파))
        ZWrite Off
        
        Pass
        {
            Name "SpriteOutline"
           
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attributes
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 uv       : TEXCOORD0;
            };

            struct Varyings
            {
                float4 vertex   : SV_POSITION;
                float4 color    : COLOR;
                float2 uv       : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _Color;
                float4 _OutlineColor;
                float _AlphaCullOff;
            CBUFFER_END
            
            // 외곽선 텍셀 검사용 컬러값 추출
            half4 SampleTexelColor(float2 uv)
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
                return color;
            }
            
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);
                OUT.color = IN.color * _Color;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                // 해당 픽셀의 알파 값이 0인지 체크 및 인접 픽셀 중 알파 값이 0이 아닌 곳을 탐색
                /*if(IN.color.a == 0)
                {
                    if( SampleTexelColor(float2(IN.uv.x + 1, IN.uv.y)).a != 0 ||
                        SampleTexelColor(float2(IN.uv.x, IN.uv.y + 1)).a != 0 ||
                        SampleTexelColor(float2(IN.uv.x - 1, IN.uv.y)).a != 0 ||
                        SampleTexelColor(float2(IN.uv.x, IN.uv.y - 1)).a != 0 )
                    {
                        color = _OutlineColor;
                        color.a = 1;
                    }
                }*/

                if(color.a < _AlphaCullOff)
                    discard;
                
                return color;
            }
            
            ENDHLSL
        }
    }
}
