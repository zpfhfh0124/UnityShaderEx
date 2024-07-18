Shader "Custom/UIShinyCustom (UIShiny)"
{
    Properties
    {
        /*[PerRendererData] */_MainTex ("Main Texture", 2D) = "white" {}  // 메인 텍스처 속성
        
        _ParamTex ("Parameter Texture", 2D) = "white" {} // 파라미터 텍스쳐
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Scripts/UIEffectCustom.hlsl"
            
            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            half4 _Color;
            half4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_TexelSize;

            struct Attributes
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
                float4 color    : COLOR;
            };

            struct Varyings
            {
                float4 vertex        : SV_POSITION;
                half4 color          : COLOR;
                float4 texcoord      : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                half2 param          : TEXCOORD2;
            };

            Varyings vert(Attributes i)
            {
                Varyings o;
                o.vertex = TransformObjectToHClip(i.vertex);
                o.worldPosition = i.vertex;
                o.param = UnpackToVec2(i.texcoord.y);
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                color = ApplyShinyEffect(color, i.param);
                
                return color;
            }
            ENDHLSL
        }
    }
    FallBack "UI/Default"
}
