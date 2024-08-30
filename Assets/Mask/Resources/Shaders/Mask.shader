Shader "URP Shader/Mask" {

    Properties {
        [IntRange]_Stencil ("Stencil", Range(0, 255)) = 1
        [Enum(UnityEngine.Rendering.CullMode)]_Cull ("Cull", float) = 2
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            ZWrite Off
            Cull [_Cull]
            ColorMask 0
            Stencil {
                Ref [_Stencil]
                Comp Always
                Pass Replace
            }
        }
    }
}