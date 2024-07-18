Shader "Hidden/Custom/UIShinyCustom (UIShiny)"
{
    Properties
    {
        /*[PerRendererData] */_MainTex ("Main Texture", 2D) = "white" {}  // 메인 텍스처 속성
        _Color ("Color", Color) = (1,1,1,1)
        
        _AlphaCutOff ("Alpha Cut Off", Range(0,1)) = 0.5
        
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        
        _ColorMask ("Color Mask", Float) = 15
        
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
            float _AlphaCutOff;

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
                float2 texcoord      : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                half2 param          : TEXCOORD2;
            };

            Varyings vert(Attributes i)
            {
                Varyings o;
                o.vertex = TransformObjectToHClip(i.vertex);
                o.color = UnpackToVec4(i.color);
                o.texcoord = i.texcoord;
                o.worldPosition = i.vertex;
                o.param = UnpackToVec2(i.texcoord.y);
                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                color = ApplyShinyEffect(color, i.param);

                // 알파 클리핑
                if (color.a < _AlphaCutOff)
                    discard;
                
                return color;
            }
            ENDHLSL
        }
    }
    FallBack "UI/Default"
}
