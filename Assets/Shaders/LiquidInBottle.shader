Shader "TNTC/LiquidInBottle"{
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

        _BumpMap ("Top Normal Map", 2D) = "bump" {}
        _BumpStrenght("Top Normal Strenght", float) = 1
        _BumpMapInner ("Inner Normal Map", 2D) = "bump" {}
        _BumpStrenghtInner("Inner Normal Strenght", float) = 1
        _TopColor("Top Section Color", Color) = (1,1,1,1)

		_Ruffle("Ruffle", float) = 10
		_PlanePosition("PlanePosition", Vector) = (0,0,0,1)
		_PlaneNormal("PlaneNormal", Vector) = (0,1,0,0)


		[IntRange] _StencilValue ("Stencil Value", Range(0,255)) = 255
    }
    
    SubShader {
		Tags {"Queue"="Geometry"}

		CGINCLUDE

		float3 _PlaneNormal;
		float3 _PlanePosition;
		float3 _Inertia;
		float _Ruffle;

		bool checkVisibility(float3 worldPos){
			float dotProd = dot(worldPos - _PlanePosition, _PlaneNormal);
			float activityX = clamp(_Inertia.x, 0, 1);
			float activityZ = clamp(_Inertia.z, 0, 1);
			dotProd += (.5/_Ruffle * sin(activityX * _Ruffle * (worldPos.x + _Time.x))); 
			dotProd += (.5/_Ruffle * cos(activityZ * _Ruffle * (worldPos.z + _Time.x)));
			return dotProd > 0;
		}

		ENDCG

		GrabPass{
            "_GrabTexture"
        }

		Stencil{
			Ref [_StencilValue]
			CompBack Always
			PassBack Replace

			CompFront Always
			PassFront Zero
		}

		
		Cull Front
		CGPROGRAM
        #pragma surface surf Standard addshadow
		#pragma vertex vert
		#pragma target 3.0

		struct Input {
			half2 uv_MainTex;
			float3 worldPos;
            float4 screenPos;
            float3 normal;
            float3 viewDir;
			float3 worldNormal;
			float4 grabUV;
    		INTERNAL_DATA
		};

		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _GrabTexture;
		fixed4 _Color;
		fixed4 _TopColor;
        float _BumpStrenght;
        half _Glossiness;
		half _Metallic;
		float _RotationSpeed;

		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input,o);
            float4 hpos = UnityObjectToClipPos (v.vertex);
            o.grabUV = ComputeGrabScreenPos(hpos);
        }

		void surf(Input IN, inout SurfaceOutputStandard o){
			if (checkVisibility(IN.worldPos))discard;
			
			float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
            screenUV *= float2(8,6);

			float4 background = tex2Dproj( _GrabTexture, IN.grabUV) * _TopColor;
			o.Albedo = lerp(background.rgb, _TopColor.rgb, _TopColor.a);

			half3 worldT = WorldNormalVector(IN, half3(1,0,0));
            half3 worldB = WorldNormalVector(IN, half3(0,1,0));
            half3 worldN = WorldNormalVector(IN, half3(0,0,1));
            half3x3 world2Tangent = half3x3(worldT, worldB, worldN);
		
			float3 n = UnpackScaleNormal(tex2D (_BumpMap, screenUV), _BumpStrenght);
			n = mul(world2Tangent, n);
            o.Normal = mul(world2Tangent, _PlaneNormal) + n;
            o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
		}
		ENDCG
		
		Cull Back

		CGPROGRAM
        #pragma surface surf Standard addshadow 
		#pragma vertex vert
        #pragma target 3.0

		sampler2D _MainTex;
        sampler2D _BumpMapInner;
        sampler2D _GrabTexture;
        float _BumpStrenghtInner;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMapInner;
			float3 worldPos;
			float4 screenPos;
			float4 grabUV;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;
		fixed4 _TopColor;

		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input,o);
            float4 hpos = UnityObjectToClipPos (v.vertex);
            o.grabUV = ComputeGrabScreenPos(hpos);
        }


		void surf(Input IN, inout SurfaceOutputStandard o) {
			if (checkVisibility(IN.worldPos)){
				discard;
			}

			float4 background = tex2Dproj( _GrabTexture, IN.grabUV) * _Color;
			o.Albedo = lerp(background.rgb, _Color.rgb, _Color.a);
			
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
            o.Normal = UnpackScaleNormal (tex2D (_BumpMapInner, IN.uv_BumpMapInner), _BumpStrenghtInner);
		}
		ENDCG

	}
}

