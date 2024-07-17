Shader "Hidden/Custom/UIShinyCustom (UIShiny)"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        
        _ColorMask ("Color Mask", Float) = 0
        
        _ParamTex ("Parameter Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
            "RenderPipeline"="UnivarsalRenderPipeline"
            "IgnoreProjector"="True"
            "CanUseSpriteAltas"="True"
            "PreviewType"="Plane"
        }
        
        stencil
        {
            Ref [_MainTex]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        
        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]
        
        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Assets/Scripts/UIEffect.hlsl"
            
            struct Attributes
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 uv       : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varying
            {
                float4 vertex   : ST_POSITION;
                float2 uv       : TEXCOORD0;
                float2 worldPos : TEXCOORD1;
                half2 param     : TEXCOORD2;
                half4 uvMask    : TEXCOORD3;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMatrial)
            float4 _TextureSampleAdd;
            float4 _ClipRect;
            CBUFFER_END

            float UnityGet2DClipping (in float2 position, in float4 clipRect)
            {
                float2 inside = step(clipRect.xy, position.xy) * step(position.xy, clipRect.zw);
                return inside.x * inside.y;
            }
            
            Varying vert(Attributes IN)
            {
                Varying OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPos = IN.vertex;
                OUT.vertex = TransformObjectToHClip(IN.vertex.xyz);
                OUT.uv = UnpackToVec2(IN.uv.x) * 2 - 0.5;
                OUT.param = UnpackToVec2(IN.uv.y);

                return OUT;
            }
            
            float4 frag(Varying IN) : SV_Target
            {
                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                color.a *= UnityGet2DClipping(IN.worldPos.xy, _ClipRect);
                
                return color;
            }
            
            ENDHLSL
        }
    }
}
