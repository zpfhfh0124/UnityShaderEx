Shader "Unlit/URP_Unlit_EX"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            struct Attribute
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uv : SV_POSITION;
            };

            Texture2D(_MainTex);
            SAMPLER(sampler_BaseMap);
            
            Varyings vert(Attribute IN)
            {
                Varyings OUT;
                OUT.positionHCS.xyz = TransformObjectToWorld(IN.vertex.xyz);
                return OUT;
            }

            half4 frag(Varyings IN)
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_BaseMap, IN.uv);
                return color;
            }

            ENDHLSL
        }
    }
}
