Shader "Custom/Stencil/UIGradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorStart ("Start Color", Color) = (1,1,1,1)
        _ColorEnd ("End Color", Color) = (1,1,1,1)

        _AlphaCull("Alpha Culling", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Opaque" }
        LOD 100

        ZWrite On

        Pass
        {
            Name "MainTexture"

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
            float _AlphaCull;

            Varyings vert(Attributes i)
            {
                Varyings o;
                o.positionHCS = TransformObjectToHClip(i.positionOS.xyz);
                o.uv = i.uv;
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                if(color.a < _AlphaCull) discard;

                return color;
            }
            ENDHLSL
        }

        Pass
        {
            Tags{"RenderType"="Transparent" "Queue"="Overlay"}
            Blend SrcAlpha OneMinusSrcAlpha

             HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFERSTART(UnityPerMaterial)

            CBUFFEREND

            ENDHLSL

        }
    }
}
