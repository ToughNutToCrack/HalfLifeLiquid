Shader "TNTC/LiquidTopSurface" {
	Properties {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (0, 0, 0, 1)
        _BumpMap ("Top Normal Map", 2D) = "bump" {}
        _BumpStrenght("Top Normal Strenght", float) = 1
		_Smoothness ("Smoothness", Range(0, 1)) = 0
		_Metallic ("Metalness", Range(0, 1)) = 0
		[HDR] _Emission ("Emission", color) = (0,0,0)
		[IntRange] _StencilValue ("Stencil Value", Range(0,255)) = 0
	}
	SubShader {
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		ZTest Off
        Blend SrcAlpha OneMinusSrcAlpha

		Stencil{
			Ref [_StencilValue]
			Comp Equal
		}

		CGPROGRAM

		#pragma surface surf Standard fullforwardshadows alpha:blend
		#pragma target 3.0

		sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _GrabTexture;
		fixed4 _Color;
        float _BumpStrenght;
		half _Smoothness;
		half _Metallic;
		half3 _Emission;
        float3 _Inertia;

		struct Input {
            float4 screenPos;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
            float inertiaMagnitude = length(_Inertia);
            inertiaMagnitude = clamp(inertiaMagnitude, 0, 1);
            float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
            screenUV *= float2(8,6);

			fixed4 col = tex2D(_MainTex, screenUV / 10);
			col *= _Color;
			o.Albedo = col.rgb;
            o.Alpha = _Color.a;
            o.Normal = UnpackScaleNormal(tex2D (_BumpMap, screenUV), _BumpStrenght * inertiaMagnitude);
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Emission = _Emission;
		}
		ENDCG
	}
	FallBack "Standard"
}