Shader "Fur/Fur Render" {
    Properties {
        _MainTex ("Main Tex", 2D) = "white" { }
        _LightDirection ("Light Direction", vector) = (0.3, 0.1, -0.1, 0)
        _Alpah ("Alpha", Range(0, 1)) = 1

        [Header(Diffuse)]
        _FrontLightColor ("Front Light Color", Color) = (1, 1, 1, 1)
        _BackLightColor ("Back Light Color", Color) = (1, 1, 1, 1)
        _DiffuseFrontIntensity ("Diffuse Front Intensity", float) = 2
        _DiffuseBackIntensity ("Diffuse Back Intensity", float) = 1.5

        [Header(Specular)]
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularIntensity ("Specular Intensity", Range(1, 10)) = 5
        _Gloss ("Gloss", Range(0, 2)) = 0.5

        [Header(Fresnel)]
        _FresnelColor ("Fresnel Color", Color) = (0, 0, 0, 0)
        _FresnelRange ("Fresnel Range", Range(0, 8)) = 0

        [Header(Fur)]
        _FurNoiseTex ("Fur Noise", 2D) = "white" { }
        _FurLength ("Fur Length", Range(0.0, 1)) = 0.05
        _FurDensity ("Fur Density", Range(0, 2)) = 0.75
        _FurThinness ("Fur Thinness", Range(0.01, 10)) = 7.5
        _FurShading ("Fur Shading", Range(0.0, 1)) = 0.15
        _FurForce ("Fur Force", Vector) = (-0.2, -0.5, 0, 0)

        [Header(Other Setting)]
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend ("SrcBlend   [One  SrcAlpha]", float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend ("DstBlend   [Zero  OneMinusSrcAlpha]", float) = 10
        [Enum(On, 1, Off, 0)]_ZWrite ("ZWrite        [On  Off]", float) = 0
    }

    SubShader {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass {
            Tags { "LightMode" = "UniversalForward" }

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 uv : TEXCOORD2;
            };
            
            sampler2D _MainTex;
            sampler2D _FurNoiseTex;
            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float3 _LightDirection;
            half _Alpah;

            half4 _FrontLightColor;
            half4 _BackLightColor;
            half _DiffuseFrontIntensity;
            half _DiffuseBackIntensity;

            half4 _SpecularColor;
            half _SpecularIntensity;
            half _Gloss;

            float4 _FurNoiseTex_ST;
            half _FurLength;
            half _FurDensity;
            half _FurThinness;
            half _FurShading;
            half4 _FurForce;
            half _FURSTEP;

            half4 _FresnelColor;
            half _FresnelRange;
            CBUFFER_END

            Varyings vert(Attributes IN) {
                Varyings OUT;

                float3 furVertex = IN.vertex.xyz + IN.normal * _FurLength * _FURSTEP;
                furVertex += clamp(mul(unity_WorldToObject, _FurForce).xyz, -1, 1) * pow(_FURSTEP, 3) * _FurLength;
                
                OUT.vertex = TransformObjectToHClip(furVertex);
                OUT.worldPos = TransformObjectToWorld(furVertex);
                OUT.worldNormal = TransformObjectToWorldNormal(IN.normal);

                OUT.uv.xy = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.uv.zw = TRANSFORM_TEX(IN.uv, _FurNoiseTex);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target {

                half3 albedo = tex2D(_MainTex, IN.uv.xy).rgb;
                albedo -= (pow(1 - _FURSTEP, 3)) * _FurShading;

                float3 worldNormal = normalize(IN.worldNormal);
                float3 worldLightDir = normalize(_LightDirection);
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - IN.worldPos.xyz);
                float3 halfDir = normalize(worldLightDir + viewDir);

                half rimFactor = pow(1 - saturate(dot(viewDir, worldNormal)), 8 - _FresnelRange);
                half4 rim = half4(_FresnelColor.xyz * rimFactor, 1);

                half halfLambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
                half oneMinusHalfLambert = 1 - halfLambert;
                
                half3 diffuse = _FrontLightColor.rgb * albedo * halfLambert * _DiffuseFrontIntensity;
                diffuse += _BackLightColor.rgb * albedo * oneMinusHalfLambert * _DiffuseBackIntensity;

                half3 specular = _SpecularColor.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss * 256) * _SpecularIntensity;

                half3 color = diffuse + specular + rim;
                
                half3 noise = tex2D(_FurNoiseTex, IN.uv.zw * _FurThinness).rgb;
                half alpha = clamp(noise - (_FURSTEP * _FURSTEP) * _FurDensity, 0, 1);
                alpha *= _Alpah;

                return half4(color, alpha);
            }
            ENDHLSL
        }
        Pass {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            #pragma target 2.0

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

            #pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            #pragma multi_compile_instancing
            #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}