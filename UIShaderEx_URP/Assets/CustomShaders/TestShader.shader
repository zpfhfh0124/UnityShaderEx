Shader "Custom/TestShader.shader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _AlphaCutoff ("Alpha Cutoff", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "RenderPipeline"="UniversalPipeline"
        }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            float _AlphaCutoff;
            
            struct Attributes
            {
                float3 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            Varyings vert(Attributes i)
            {
                Varyings o;
                o.vertex = TransformObjectToHClip(i.vertex);
                o.uv = i.uv; // UV 좌표를 직접 전달
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                // Alpha Clipping
                if (color.a < _AlphaCutoff)
                    discard;

                return color;
            }
            ENDHLSL
        }
    }
    FallBack "UI/Default"
}
