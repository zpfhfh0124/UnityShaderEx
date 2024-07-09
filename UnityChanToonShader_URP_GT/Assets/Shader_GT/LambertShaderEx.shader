Shader "GT/BRDF/LambertShaderEx"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor("BaseColor", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline"  }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv         : TEXCOORD0;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS   : SV_POSITION;
                float2 uv            : TEXCOORD0;
                float3 normal        : TEXCOORD1;
                float3 lightDir      : TEXCOORD2;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _BaseColor;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.normal = TransformObjectToWorldNormal(IN.normalOS);
                OUT.lightDir = normalize(_MainLightPosition.xyz); // Input.hlsl -> _MainLightPosition
                return OUT;
            }

            half4 frag (Varyings IN) : SV_Target
            {
                // 버텍스 사이 픽셀 노멀 길이 1로 정규화.
                IN.normal = normalize(IN.normal);
                
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                color *= _BaseColor;

                // 라이트 계산 적용
                float NdotL = saturate(dot(IN.lightDir, IN.normal)); // saturate : 0 이하는 0으로 조정. dot : 두 벡터의 내적을 계산
                half3 ambient = SampleSH(IN.normal); // 노멀 방향의 GI 컬러 정보
                half3 lighting = NdotL * _MainLightColor.rgb + ambient;
                color.rgb *= lighting;
                return color;
            }
            ENDHLSL
        }
        
    }
}
