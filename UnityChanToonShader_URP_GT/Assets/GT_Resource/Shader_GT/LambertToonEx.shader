Shader "GT/LambertToonEx"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LambertThresh("LambertThresh", float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Varyings
            {
                float4 vertex   : SV_POSITION;
                float2 uv       : TEXCOORD0;
                float3 normal   : TEXCOORD1;
                float3 lightDir : TEXCOORD2;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _LambertThresh;
            CBUFFER_END

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                // 입력 버텍스 좌표
                VertexPositionInputs inputs = GetVertexPositionInputs(IN.vertex.xyz);
                OUT.vertex = inputs.positionCS;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.normal = normalize(TransformObjectToWorldNormal(IN.normal));
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                Light mainLight = GetMainLight();
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                
                // 노말 벡터 내적 -> 0 ~ 1 정규화
                float uNormalDot = saturate(dot(mainLight.direction.xyz, IN.normal)*0.5f + 0.5f);
                // uNormalDot < _LambertThresh ? 1 : 0
                float ramp = step(uNormalDot, _LambertThresh);
                // mainLight.color
                color.rgb = lerp(color, color * mainLight.color, ramp);
                return color;
            }
            ENDHLSL
        }
    }
}
