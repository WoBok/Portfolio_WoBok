
Shader "URP Shader/Outline" {
    Properties {
        _BaseColor ("Color", Color) = (1, 1, 1, 1)
        _Width ("Width", Float) = 0.1
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass {
            HLSLPROGRAM

            #pragma vertex Vertex
            #pragma fragment Fragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 positionOS : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings {
                float2 uv : TEXCOORD0;
                float4 positionCS : SV_POSITION;
            };
            
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            half _Width;
            CBUFFER_END

            Varyings Vertex(Attributes input) {

                Varyings output;
                
                output.positionCS = mul(UNITY_MATRIX_MVP, input.positionOS);

                output.uv = input.texcoord.xy ;

                return output;
            }

            half4 Fragment(Varyings input) : SV_Target {
                float2 uv = input.uv;

                half top = step(1 - _Width, uv.y) * step(uv.y, 1);
                half bottom = step(0, uv.y) * step(uv.y, _Width);

                half left = step(0, uv.x) * step(uv.x, _Width);
                half right = step(1 - _Width, uv.x) * step(uv.x, 1);

                half alpha = saturate(top + bottom + left + right);

                return half4(_BaseColor.rgb, alpha);
            }
            ENDHLSL
        }
    }
}