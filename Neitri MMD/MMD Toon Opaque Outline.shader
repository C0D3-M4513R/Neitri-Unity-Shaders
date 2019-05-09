// by Neitri, free of charge, free to redistribute
// downloaded from https://github.com/netri/Neitri-Unity-Shaders

Shader "Neitri/MMD Toon Opaque Outline" {
	Properties {
		[Header(Main)] 
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Glossiness", Range(0, 1)) = 0

		[Header(Normal Map)]
		_BumpMap("Normal Map", 2D) = "bump" {}
		_BumpScale("Weight", Range(0, 2)) = 0

		[Header(Emission)]
		_EmissionMap ("Texture", 2D) = "black" {}
		[HDR] _EmissionColor ("Color", Color) = (1,1,1,1)

		[Header(Shading Ramp)]
		[HDR] _RampColorAdjustment("Color", Color) = (1,1,1,1)
		_ShadingRampStretch("Ramp stretch", Range(0, 1)) = 0
		[NoScaleOffset] _Ramp("Ramp", 2D) = "white" {}

		[Header(Matcap)]
		[Enum(Disabled,0,Add to final color,1,Multiply final color,2)] _MatcapType("Type", Range(0, 2)) = 2
		[HDR] _MatcapColorAdjustment("Color", Color) = (1,1,1,1)
		[Enum(Anchored to direction to camera,0,Anchored to camera rotation,1,Anchored to world up,2)] _MatcapAnchor("Anchor", Range(0, 2)) = 0
		[NoScaleOffset] _Matcap("Matcap", 2D) = "white" {}

		[Header(Shadow)]
		_Shadow ("Shadow darkness", Range(0, 1)) = 0.7
		[HDR] _ShadowColor ("Shadow color", Color) = (0,0,0,1)

		[Header(Baked Lighting)]
		_BakedLightingFlatness ("Baked lighting flatness", Range(0, 1)) = 0.9
		[Toggle(_)] _UseFakeLight("Approximate fake light", Range(0, 1)) = 1

		[Header(Change color over time)]
		[Toggle(_)]_UseColorOverTime ("Enable", Range(0, 1)) = 0
		_ColorOverTime_Ramp ("Colors Texture", 2D) = "white" {}
		_ColorOverTime_Speed ("Time Speed Multiplier", Range(0.01, 10)) = 0.1

		[Header(Raymarched Pattern)]
		[Enum(None,0,Spheres,1,Hearts,2)] _Raymarcher_Type ("Type", Range(0, 2)) = 0
		_Raymarcher_Scale("Scale", Range(0.5, 1.5)) = 1.0

		[Header(Other)]
		[Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 2
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
		[Toggle(_)] _UseDitheredTransparency ("Dithered Transparency", Range(0, 1)) = 1
		//[Toggle(_)] _DebugInt1("Debug Int 1", Range(0, 1)) = 1
		//[Toggle(_)] _DebugInt2("Debug Int 2", Range(0, 1)) = 1
		//[Toggle(_)] _UseMeshDeformation ("Mesh Deformation", Range(0, 1)) = 0
	}
	SubShader {
		Tags {
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
		}
		
		Pass {
			Name "ForwardBase"
			Tags { "LightMode" = "ForwardBase" }
			Cull [_Cull]
			ZTest [_ZTest]
			Blend One Zero
			AlphaToMask On
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#define UNITY_PASS_FORWARDBASE
			#define IS_OUTLINE_SHADER
			#pragma only_renderers d3d11 glcore gles
			#pragma target 4.0
			#pragma multi_compile_fwdbase
			#pragma multi_compile_fog
			#include "Base.cginc"
			ENDCG
		}
		Pass {
			Name "ForwardAdd"
			Tags { "LightMode" = "ForwardAdd" }
			Cull [_Cull]
			ZTest [_ZTest]
			Blend SrcAlpha One
			AlphaToMask On
			ZWrite Off
			Fog { Color (0,0,0,0) }
			ZTest LEqual
			CGPROGRAM
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag
			#define UNITY_PASS_FORWARDADD
			#pragma only_renderers d3d11 glcore gles
			#pragma target 4.0
			#pragma multi_compile_fwdadd_fullshadows
			#pragma multi_compile_fog
			#include "Base.cginc"
			ENDCG
		}
		Pass {
			Name "ShadowCaster"
			Tags { "LightMode" = "ShadowCaster" }
			ZWrite On
			ZTest LEqual
			CGPROGRAM
			#pragma target 4.0
			#pragma vertex vertShadowCaster
			#pragma fragment fragShadowCaster
			#include "Base.cginc"
			ENDCG
		}
	}	
	FallBack "Neitri/Neitri/MMD Toon Opaque"
	CustomEditor "NeitriMMDToonEditor"
}