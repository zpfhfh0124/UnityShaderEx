Shader "Unlit/URP_Unlit_EX"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //#include 
            
            struct Attribute
            {
                float2 uv : TEXCOORD0;
                float4 vertex : POSITION;
            };

            struct Varyings
            {
                
            };

            Attribute vert()
            {
                
            }

            Varyings frag()
            {
                
            }

            ENDHLSL
        }
    }
}
