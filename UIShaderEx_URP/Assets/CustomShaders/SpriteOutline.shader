Shader "Custom/SpriteOutline"
{
    Properties
    {
        _MainTex("Sprite Texture", 2D) = "white" {}
        _MainTex_ST("Texture ST", Vector) = (1,1,0,0)
        _Color("Tint", Color) = (1,1,1,1)
        _LineThickness("Line Thickness", Float) = 0
     
        unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        unity_ShadowMasks("unity_shadowMask", 2DArray) = "" {}
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RederPipeline"="UnivarsalPipeline"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "IgnoreProjector"="True"
            "UniversalMaterialType" = "Lit"
        }
        
        Pass
        {
            // Stencil Buffers
            Blend SrcAlpha OneMinusSrcAlpha // (색1 알파) + (색2 * (1 - 색1 알파))
            ZWrite Off
            ColorMask A // ColorMask 를 A로 설정하면 스텐실이 설정되어도 렌더링되지 않음.
        
            Name "SpriteOutline"
            Tags
            {
                "LightMode" = "SetStencilPass" // 멀티패스 추가    
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv          : TEXCOORD0;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            // 셰이더의 프로퍼티 코드를 작성 (선언부)
            // 렌더링을 최적화하기 위해 SRP Batcher를 동작시키는것은 CBUFFER 구문을 다른 Pass와 같게 할 필요가 있다.
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;
                half4 _Color;
                float _LineThickness;
            CBUFFER_END
            
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // _LineThickness의 길이로 떨어진 곳에 위치한 픽셀의 투명도를 체크.
                float offset1 = _LineThickness;
                float offset2 = _LineThickness * 0.7f;

                float alpha_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).a;

                // 주위 8개 픽셀의 투명도를 체크. -> 현재 텍셀 기준으로 오프셋(라인의 두께)을 계산하여 인접한 8개의 텍셀의 위치를 찾아 알파값을 참조 
                float alpha_1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(offset1, 0)).a;
                float alpha_2 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(-offset1, 0)).a;
                float alpha_3 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(0, offset1)).a;
                float alpha_4 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(0, -offset1)).a;
                float alpha_5 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(offset2, offset2)).a;
                float alpha_6 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(-offset2, offset2)).a;
                float alpha_7 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(-offset2, -offset2)).a;
                float alpha_8 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(offset2, -offset2)).a;

                half totalAlpha = alpha_0 + alpha_1 + alpha_2 + alpha_3 + alpha_4 + alpha_5 + alpha_6 + alpha_7 + alpha_8;

                half4 color = float4(0, 0, 0, 0);
                color.a = saturate(totalAlpha * _Color.a); // 알파 합계 * 컬러 알파 (알파 블렌딩) -> 0 ~ 1 클램핑

                // discard가 호출되면 스텐실이 갱신되지 않은 정점을 사용해서 아웃라인으로 있는 부분만 스텐실 값을 저장하도록 한다.
                // 픽셀이 불투명한 경우, 아웃라인이 아닌 그림의 내부에 대응한다.
                if (alpha_0 > 0) discard;

                // 주위에 불투명한 픽셀이 없는 경우는 아웃라인이 아닌 margin에 대응.
                if (color.a < 0.02f) discard;

                return color;
            }
            
            ENDHLSL
        }
    }
}
