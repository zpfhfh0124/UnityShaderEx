Shader "AnyPortrait/Custom URP/Unlit/Linear/Outline Stencil Alpha Blend"
{
    Properties
    {
        [NoScaleOffset] _MainTex("MainTex", 2D) = "white" {}
        _MainTex_ST("MainTex_ST", Vector) = (1, 1, 0, 0)
        _Color("Color", Color) = (0.5019608, 0.5019608, 0.5019608, 1)
        _LineThickness("LineThickness", Float) = 0
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
        SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "UniversalMaterialType" = "Unlit"
            "Queue" = "Transparent"
            "ShaderGraphShader" = "true"
            "ShaderGraphTargetId" = ""
        }



        //-----------------------------------------------
        // >> Add a Pass that sets Stencil Buffers <<
        //-----------------------------------------------
        Pass
        {
            //This is the Pass for storing the Stencil.
            //Since we will override the material settings in the Renderer Data, the Stencil code is skipped here.

            Tags { "LightMode" = "SetStencilPass" }
            Blend SrcAlpha OneMinusSrcAlpha

            //Set it to "ColorMask A" to prevent rendering.
            ZWrite Off
            ColorMask A

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float2 uv           : TEXCOORD0;
            };
            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                float2 uv           : TEXCOORD0;
            };


            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            //SRP Batcher works only when the syntax of CBUFFER is written the same as that of other passes.
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_TexelSize;
                float4 _MainTex_ST;
                float4 _Color;
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
                //Check the transparency of other pixels at a distance of "_LineThickness".
                float offset1 = _LineThickness;
                float offset2 = _LineThickness * 0.7f;

                //By checking the alpha of 8 surrounding pixels together, it is determined whether it is an outline or not.
                float alpha_0 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv).a;
                float alpha_1 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(offset1,    0)).a;
                float alpha_2 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(-offset1,   0)).a;
                float alpha_3 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(0,          offset1)).a;
                float alpha_4 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(0,          -offset1)).a;

                float alpha_5 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(offset2,    offset2)).a;
                float alpha_6 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(-offset2,   offset2)).a;
                float alpha_7 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(-offset2,   -offset2)).a;
                float alpha_8 = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv + float2(offset2,    -offset2)).a;

                half totalAlpha = alpha_0 + alpha_1 + alpha_2 + alpha_3 + alpha_4
                                + alpha_5 + alpha_6 + alpha_7 + alpha_8;

                float4 c = float4(0, 0, 0, 0);
                c.a = saturate(totalAlpha * _Color.a);

                //The code uses the feature that "Stencil is not set when discard is called".
                if (alpha_0 > 0.5f)
                {
                    discard;
                }

                if (c.a < 0.02f)
                {
                    discard;
                }

                return c;
            }
            ENDHLSL
        }
        //----------------------------------------------------------------




        Pass
        {
            Name "Sprite Unlit"
            Tags
            {
                "LightMode" = "Universal2D"
            }

        // Render State
        Cull Off
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma exclude_renderers d3d11_9x
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ DEBUG_DISPLAY
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SPRITEUNLIT
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */

        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
    {
         float3 positionOS : POSITION;
         float3 normalOS : NORMAL;
         float4 tangentOS : TANGENT;
         float4 uv0 : TEXCOORD0;
         float4 color : COLOR;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
         float4 positionCS : SV_POSITION;
         float3 positionWS;
         float4 texCoord0;
         float4 color;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
         float4 uv0;
    };
    struct VertexDescriptionInputs
    {
         float3 ObjectSpaceNormal;
         float3 ObjectSpaceTangent;
         float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
         float4 positionCS : SV_POSITION;
         float3 interp0 : INTERP0;
         float4 interp1 : INTERP1;
         float4 interp2 : INTERP2;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        ZERO_INITIALIZE(PackedVaryings, output);
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyzw = input.texCoord0;
        output.interp2.xyzw = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.texCoord0 = input.interp1.xyzw;
        output.color = input.interp2.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }


    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _MainTex_TexelSize;
float4 _MainTex_ST;
float4 _Color;
float _LineThickness;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
    Out = A * B;
}

void Unity_Power_float3(float3 A, float3 B, out float3 Out)
{
    Out = pow(A, B);
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
    Out = A * B;
}

/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

    #ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
    float4 _Property_635eb48aba3d44e18e34961a3b24d717_Out_0 = _MainTex_ST;
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_R_1 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[0];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_G_2 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[1];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_B_3 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[2];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_A_4 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[3];
    float2 _Vector2_e7e1269ae0b74a8893499504293dfe91_Out_0 = float2(_Split_a6ad0964cf174741bcb30d2208dbebbb_R_1, _Split_a6ad0964cf174741bcb30d2208dbebbb_G_2);
    float2 _Vector2_e115e4f643b04f9a92d11f62f8636e03_Out_0 = float2(_Split_a6ad0964cf174741bcb30d2208dbebbb_B_3, _Split_a6ad0964cf174741bcb30d2208dbebbb_A_4);
    float2 _TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3;
    Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e7e1269ae0b74a8893499504293dfe91_Out_0, _Vector2_e115e4f643b04f9a92d11f62f8636e03_Out_0, _TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3);
    float4 _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.tex, _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.samplerstate, _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.GetTransformedUV(_TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3));
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_R_4 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.r;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_G_5 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.g;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_B_6 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.b;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_A_7 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.a;
    float4 _Combine_08f9ddb984644f26ae165fea60f90d43_RGBA_4;
    float3 _Combine_08f9ddb984644f26ae165fea60f90d43_RGB_5;
    float2 _Combine_08f9ddb984644f26ae165fea60f90d43_RG_6;
    Unity_Combine_float(_SampleTexture2D_44dba45b671443f781654cd6e73d68d4_R_4, _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_G_5, _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_B_6, 0, _Combine_08f9ddb984644f26ae165fea60f90d43_RGBA_4, _Combine_08f9ddb984644f26ae165fea60f90d43_RGB_5, _Combine_08f9ddb984644f26ae165fea60f90d43_RG_6);
    float4 _Property_76a516d25a1e41c2a45f020f66aec026_Out_0 = _Color;
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_R_1 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[0];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_G_2 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[1];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_B_3 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[2];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_A_4 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[3];
    float4 _Combine_d667bc98ef0446b88fca61e4f951db2a_RGBA_4;
    float3 _Combine_d667bc98ef0446b88fca61e4f951db2a_RGB_5;
    float2 _Combine_d667bc98ef0446b88fca61e4f951db2a_RG_6;
    Unity_Combine_float(_Split_2cbcbb642b894acc9186c8ffdfec3dd8_R_1, _Split_2cbcbb642b894acc9186c8ffdfec3dd8_G_2, _Split_2cbcbb642b894acc9186c8ffdfec3dd8_B_3, 0, _Combine_d667bc98ef0446b88fca61e4f951db2a_RGBA_4, _Combine_d667bc98ef0446b88fca61e4f951db2a_RGB_5, _Combine_d667bc98ef0446b88fca61e4f951db2a_RG_6);
    float3 _Multiply_03727ec1412346ccb457a276fc212b1e_Out_2;
    Unity_Multiply_float3_float3(_Combine_d667bc98ef0446b88fca61e4f951db2a_RGB_5, float3(4.595, 4.595, 4.595), _Multiply_03727ec1412346ccb457a276fc212b1e_Out_2);
    float3 _Multiply_7602cb1c25444ad78ba8a588b780db72_Out_2;
    Unity_Multiply_float3_float3(_Combine_08f9ddb984644f26ae165fea60f90d43_RGB_5, _Multiply_03727ec1412346ccb457a276fc212b1e_Out_2, _Multiply_7602cb1c25444ad78ba8a588b780db72_Out_2);
    float3 _Power_f70cad9c0d884e76acd4e571e15c67f8_Out_2;
    Unity_Power_float3(_Multiply_7602cb1c25444ad78ba8a588b780db72_Out_2, float3(2.2, 2.2, 2.2), _Power_f70cad9c0d884e76acd4e571e15c67f8_Out_2);
    float _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2;
    Unity_Multiply_float_float(_SampleTexture2D_44dba45b671443f781654cd6e73d68d4_A_7, _Split_2cbcbb642b894acc9186c8ffdfec3dd8_A_4, _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2);
    surface.BaseColor = _Power_f70cad9c0d884e76acd4e571e15c67f8_Out_2;
    surface.Alpha = _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteUnlitPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "SceneSelectionPass"
    Tags
    {
        "LightMode" = "SceneSelectionPass"
    }

        // Render State
        Cull Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma exclude_renderers d3d11_9x
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
    #define SCENESELECTIONPASS 1

        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */

        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
    {
         float3 positionOS : POSITION;
         float3 normalOS : NORMAL;
         float4 tangentOS : TANGENT;
         float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
         float4 positionCS : SV_POSITION;
         float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
         float4 uv0;
    };
    struct VertexDescriptionInputs
    {
         float3 ObjectSpaceNormal;
         float3 ObjectSpaceTangent;
         float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
         float4 positionCS : SV_POSITION;
         float4 interp0 : INTERP0;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        ZERO_INITIALIZE(PackedVaryings, output);
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }


    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _MainTex_TexelSize;
float4 _MainTex_ST;
float4 _Color;
float _LineThickness;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
    Out = A * B;
}

/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

    #ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
    float4 _Property_635eb48aba3d44e18e34961a3b24d717_Out_0 = _MainTex_ST;
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_R_1 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[0];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_G_2 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[1];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_B_3 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[2];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_A_4 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[3];
    float2 _Vector2_e7e1269ae0b74a8893499504293dfe91_Out_0 = float2(_Split_a6ad0964cf174741bcb30d2208dbebbb_R_1, _Split_a6ad0964cf174741bcb30d2208dbebbb_G_2);
    float2 _Vector2_e115e4f643b04f9a92d11f62f8636e03_Out_0 = float2(_Split_a6ad0964cf174741bcb30d2208dbebbb_B_3, _Split_a6ad0964cf174741bcb30d2208dbebbb_A_4);
    float2 _TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3;
    Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e7e1269ae0b74a8893499504293dfe91_Out_0, _Vector2_e115e4f643b04f9a92d11f62f8636e03_Out_0, _TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3);
    float4 _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.tex, _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.samplerstate, _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.GetTransformedUV(_TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3));
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_R_4 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.r;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_G_5 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.g;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_B_6 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.b;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_A_7 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.a;
    float4 _Property_76a516d25a1e41c2a45f020f66aec026_Out_0 = _Color;
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_R_1 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[0];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_G_2 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[1];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_B_3 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[2];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_A_4 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[3];
    float _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2;
    Unity_Multiply_float_float(_SampleTexture2D_44dba45b671443f781654cd6e73d68d4_A_7, _Split_2cbcbb642b894acc9186c8ffdfec3dd8_A_4, _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2);
    surface.Alpha = _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "ScenePickingPass"
    Tags
    {
        "LightMode" = "Picking"
    }

        // Render State
        Cull Back

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma exclude_renderers d3d11_9x
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
    #define SCENEPICKINGPASS 1

        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */

        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
    {
         float3 positionOS : POSITION;
         float3 normalOS : NORMAL;
         float4 tangentOS : TANGENT;
         float4 uv0 : TEXCOORD0;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
         float4 positionCS : SV_POSITION;
         float4 texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
         float4 uv0;
    };
    struct VertexDescriptionInputs
    {
         float3 ObjectSpaceNormal;
         float3 ObjectSpaceTangent;
         float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
         float4 positionCS : SV_POSITION;
         float4 interp0 : INTERP0;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        ZERO_INITIALIZE(PackedVaryings, output);
        output.positionCS = input.positionCS;
        output.interp0.xyzw = input.texCoord0;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.texCoord0 = input.interp0.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }


    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _MainTex_TexelSize;
float4 _MainTex_ST;
float4 _Color;
float _LineThickness;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
    Out = A * B;
}

/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

    #ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
    float4 _Property_635eb48aba3d44e18e34961a3b24d717_Out_0 = _MainTex_ST;
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_R_1 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[0];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_G_2 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[1];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_B_3 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[2];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_A_4 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[3];
    float2 _Vector2_e7e1269ae0b74a8893499504293dfe91_Out_0 = float2(_Split_a6ad0964cf174741bcb30d2208dbebbb_R_1, _Split_a6ad0964cf174741bcb30d2208dbebbb_G_2);
    float2 _Vector2_e115e4f643b04f9a92d11f62f8636e03_Out_0 = float2(_Split_a6ad0964cf174741bcb30d2208dbebbb_B_3, _Split_a6ad0964cf174741bcb30d2208dbebbb_A_4);
    float2 _TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3;
    Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e7e1269ae0b74a8893499504293dfe91_Out_0, _Vector2_e115e4f643b04f9a92d11f62f8636e03_Out_0, _TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3);
    float4 _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.tex, _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.samplerstate, _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.GetTransformedUV(_TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3));
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_R_4 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.r;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_G_5 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.g;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_B_6 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.b;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_A_7 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.a;
    float4 _Property_76a516d25a1e41c2a45f020f66aec026_Out_0 = _Color;
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_R_1 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[0];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_G_2 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[1];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_B_3 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[2];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_A_4 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[3];
    float _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2;
    Unity_Multiply_float_float(_SampleTexture2D_44dba45b671443f781654cd6e73d68d4_A_7, _Split_2cbcbb642b894acc9186c8ffdfec3dd8_A_4, _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2);
    surface.Alpha = _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"

    ENDHLSL
}
Pass
{
    Name "Sprite Unlit"
    Tags
    {
        "LightMode" = "UniversalForward"
    }

        // Render State
        Cull Off
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

        // Debug
        // <None>

        // --------------------------------------------------
        // Pass

        HLSLPROGRAM

        // Pragmas
        #pragma target 2.0
    #pragma exclude_renderers d3d11_9x
    #pragma vertex vert
    #pragma fragment frag

        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>

        // Keywords
        #pragma multi_compile _ DEBUG_DISPLAY
        // GraphKeywords: <None>

        // Defines
        #define _SURFACE_TYPE_TRANSPARENT 1
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_COLOR
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_COLOR
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SPRITEFORWARD
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

        // Includes
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreInclude' */

        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

        // --------------------------------------------------
        // Structs and Packing

        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */

        struct Attributes
    {
         float3 positionOS : POSITION;
         float3 normalOS : NORMAL;
         float4 tangentOS : TANGENT;
         float4 uv0 : TEXCOORD0;
         float4 color : COLOR;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
         float4 positionCS : SV_POSITION;
         float3 positionWS;
         float4 texCoord0;
         float4 color;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
         float4 uv0;
    };
    struct VertexDescriptionInputs
    {
         float3 ObjectSpaceNormal;
         float3 ObjectSpaceTangent;
         float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
         float4 positionCS : SV_POSITION;
         float3 interp0 : INTERP0;
         float4 interp1 : INTERP1;
         float4 interp2 : INTERP2;
        #if UNITY_ANY_INSTANCING_ENABLED
         uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
         uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
         uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
         FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

        PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        ZERO_INITIALIZE(PackedVaryings, output);
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyzw = input.texCoord0;
        output.interp2.xyzw = input.color;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.texCoord0 = input.interp1.xyzw;
        output.color = input.interp2.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }


    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
float4 _MainTex_TexelSize;
float4 _MainTex_ST;
float4 _Color;
float _LineThickness;
CBUFFER_END

// Object and Global properties
SAMPLER(SamplerState_Linear_Repeat);
TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

// Graph Includes
// GraphIncludes: <None>

// -- Property used by ScenePickingPass
#ifdef SCENEPICKINGPASS
float4 _SelectionID;
#endif

// -- Properties used by SceneSelectionPass
#ifdef SCENESELECTIONPASS
int _ObjectId;
int _PassValue;
#endif

// Graph Functions

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Combine_float(float R, float G, float B, float A, out float4 RGBA, out float3 RGB, out float2 RG)
{
    RGBA = float4(R, G, B, A);
    RGB = float3(R, G, B);
    RG = float2(R, G);
}

void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
{
    Out = A * B;
}

void Unity_Power_float3(float3 A, float3 B, out float3 Out)
{
    Out = pow(A, B);
}

void Unity_Multiply_float_float(float A, float B, out float Out)
{
    Out = A * B;
}

/* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

    #ifdef FEATURES_GRAPH_VERTEX
Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
{
return output;
}
#define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
#endif

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    UnityTexture2D _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0 = UnityBuildTexture2DStructNoScale(_MainTex);
    float4 _Property_635eb48aba3d44e18e34961a3b24d717_Out_0 = _MainTex_ST;
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_R_1 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[0];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_G_2 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[1];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_B_3 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[2];
    float _Split_a6ad0964cf174741bcb30d2208dbebbb_A_4 = _Property_635eb48aba3d44e18e34961a3b24d717_Out_0[3];
    float2 _Vector2_e7e1269ae0b74a8893499504293dfe91_Out_0 = float2(_Split_a6ad0964cf174741bcb30d2208dbebbb_R_1, _Split_a6ad0964cf174741bcb30d2208dbebbb_G_2);
    float2 _Vector2_e115e4f643b04f9a92d11f62f8636e03_Out_0 = float2(_Split_a6ad0964cf174741bcb30d2208dbebbb_B_3, _Split_a6ad0964cf174741bcb30d2208dbebbb_A_4);
    float2 _TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3;
    Unity_TilingAndOffset_float(IN.uv0.xy, _Vector2_e7e1269ae0b74a8893499504293dfe91_Out_0, _Vector2_e115e4f643b04f9a92d11f62f8636e03_Out_0, _TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3);
    float4 _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0 = SAMPLE_TEXTURE2D(_Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.tex, _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.samplerstate, _Property_479672c31fd94b9d8dbf0253da6a3af9_Out_0.GetTransformedUV(_TilingAndOffset_a543a7de6e3648e191e03c54460f0674_Out_3));
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_R_4 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.r;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_G_5 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.g;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_B_6 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.b;
    float _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_A_7 = _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_RGBA_0.a;
    float4 _Combine_08f9ddb984644f26ae165fea60f90d43_RGBA_4;
    float3 _Combine_08f9ddb984644f26ae165fea60f90d43_RGB_5;
    float2 _Combine_08f9ddb984644f26ae165fea60f90d43_RG_6;
    Unity_Combine_float(_SampleTexture2D_44dba45b671443f781654cd6e73d68d4_R_4, _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_G_5, _SampleTexture2D_44dba45b671443f781654cd6e73d68d4_B_6, 0, _Combine_08f9ddb984644f26ae165fea60f90d43_RGBA_4, _Combine_08f9ddb984644f26ae165fea60f90d43_RGB_5, _Combine_08f9ddb984644f26ae165fea60f90d43_RG_6);
    float4 _Property_76a516d25a1e41c2a45f020f66aec026_Out_0 = _Color;
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_R_1 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[0];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_G_2 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[1];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_B_3 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[2];
    float _Split_2cbcbb642b894acc9186c8ffdfec3dd8_A_4 = _Property_76a516d25a1e41c2a45f020f66aec026_Out_0[3];
    float4 _Combine_d667bc98ef0446b88fca61e4f951db2a_RGBA_4;
    float3 _Combine_d667bc98ef0446b88fca61e4f951db2a_RGB_5;
    float2 _Combine_d667bc98ef0446b88fca61e4f951db2a_RG_6;
    Unity_Combine_float(_Split_2cbcbb642b894acc9186c8ffdfec3dd8_R_1, _Split_2cbcbb642b894acc9186c8ffdfec3dd8_G_2, _Split_2cbcbb642b894acc9186c8ffdfec3dd8_B_3, 0, _Combine_d667bc98ef0446b88fca61e4f951db2a_RGBA_4, _Combine_d667bc98ef0446b88fca61e4f951db2a_RGB_5, _Combine_d667bc98ef0446b88fca61e4f951db2a_RG_6);
    float3 _Multiply_03727ec1412346ccb457a276fc212b1e_Out_2;
    Unity_Multiply_float3_float3(_Combine_d667bc98ef0446b88fca61e4f951db2a_RGB_5, float3(4.595, 4.595, 4.595), _Multiply_03727ec1412346ccb457a276fc212b1e_Out_2);
    float3 _Multiply_7602cb1c25444ad78ba8a588b780db72_Out_2;
    Unity_Multiply_float3_float3(_Combine_08f9ddb984644f26ae165fea60f90d43_RGB_5, _Multiply_03727ec1412346ccb457a276fc212b1e_Out_2, _Multiply_7602cb1c25444ad78ba8a588b780db72_Out_2);
    float3 _Power_f70cad9c0d884e76acd4e571e15c67f8_Out_2;
    Unity_Power_float3(_Multiply_7602cb1c25444ad78ba8a588b780db72_Out_2, float3(2.2, 2.2, 2.2), _Power_f70cad9c0d884e76acd4e571e15c67f8_Out_2);
    float _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2;
    Unity_Multiply_float_float(_SampleTexture2D_44dba45b671443f781654cd6e73d68d4_A_7, _Split_2cbcbb642b894acc9186c8ffdfec3dd8_A_4, _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2);
    surface.BaseColor = _Power_f70cad9c0d884e76acd4e571e15c67f8_Out_2;
    surface.Alpha = _Multiply_c96db7f9379f4fddb8c3dcbed3bfa094_Out_2;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS.xyz;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}
    SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);







    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN                output.FaceSign =                                   IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}

    // --------------------------------------------------
    // Main

    #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/2D/ShaderGraph/Includes/SpriteUnlitPass.hlsl"

    ENDHLSL
}
    }
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
        FallBack "Hidden/Shader Graph/FallbackError"
}