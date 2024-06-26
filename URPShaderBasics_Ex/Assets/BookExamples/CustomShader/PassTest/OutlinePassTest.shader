Shader "Custom/PassTest/OutlinePassTest"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _OutlineColor("Outline Color", Color) = (1, 0, 0, 1)
        _OutlineDistance("Outline Distance", Float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        
        Pass
        {
            Name "TestPassNameMain"

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

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);
                return color;
            }
            ENDHLSL
        }

        Pass
        {
            Name "TestNameOutline"
            Tags {"LightMode" = "Outline"} // ForwardRenderer �ּ��� ���� ���Ŀ� Render Objects�� �߰��� �� Filters > LightMode Tags�� Outline �� �߰��ϸ� �߰� �н��� �׷���
            ZWrite Off
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
            };

            half4 _OutlineColor;
            half _OutlineDistance;

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                //OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                
                // ���� �븻 ���, ī�޶� �Ÿ��� ���� ���� ���� X
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 normalWS = mul(UNITY_MATRIX_M, IN.normalOS.xyz);
                positionWS += normalWS * _OutlineDistance;
                OUT.positionHCS = TransformWorldToHClip(positionWS);

                /*
                // ���� ��� ���, ī�޶� �Ÿ��� ���� ���� ���� O
                float3 positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                float3 normalWS = mul(UNITY_MATRIX_M, IN.normalOS.xyz);
                float distToCam = length(_WorldSpaceCameraPos - positionWS);
                positionWS += normalWS * _OutlineDistance * distToCam;
                OUT.positionHCS = TransformWorldToHClip(positionWS);

                // ��ũ�� ��� ���, ī�޶� �Ÿ��� ���� ���� ���� O
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                float3 clipNormal = TransformObjectToHClip(IN.normalOS * 100); // 100�� ���ϴ� ���� : 1 ���Ϸ� ���� ���� �븻 ������ Ŭ�������̽��� �۽���Ƽ�갡 ����Ǹ鼭 ȭ�� �ٱ��ʿ����� ������ �������� �ְ��� �߻��ϹǷ� Ŭ�� ��ȯ ���� ������ �������� ���� ������ ����� ū ���ͷ� ����
                clipNormal = normalize(float3(clipNormal.xy, 0)); // �ſ� ū ���Ⱚ�� ����ȭ
                OUT.positionHCS.xyz += normalize(clipNormal) * _OutlineDistance * OUT.positionHCS.w; // Ŭ�������� w ���� ī�޶� ������ z���� ����. ��, ī�޶�κ��� ���ý������� �Ÿ�
                */
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //half4 retColor = half4(1, 0, 0, 1);
                //retColor.rgb = IN.positionHCS.y - 200;
                //return retColor;
                return _OutlineColor;
            }
            ENDHLSL
        }
    }
}