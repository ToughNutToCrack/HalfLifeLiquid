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
        _CrossColor("Cross Section Color", Color) = (1,1,1,1)
        
		_PlanePosition("PlanePosition", Vector) = (0,0,0,1)
		_PlaneNormal("PlaneNormal", Vector) = (0,1,0,0)

		[IntRange] _StencilRef ("Stencil Reference Value", Range(0,255)) = 255
    }
    
    SubShader {
		Tags {"Queue"="Geometry"}

		CGINCLUDE

		float3 _PlaneNormal;
		float3 _PlanePosition;
		float3 _Activity;

		bool checkVisibility(float3 worldPos){
			float dotProd = dot(worldPos - _PlanePosition, _PlaneNormal);
			float activityX = clamp(_Activity.x, 0, 1);
			float activityZ = clamp(_Activity.z, 0, 1);
			dotProd += (.005 * sin(activityX * 100 * (worldPos.x + _Time.x))); 
			dotProd += (.005 * cos(activityZ * 100 * (worldPos.z + _Time.x)));
			return dotProd > 0;
		}

		ENDCG
		
		Cull Front

		CGPROGRAM
        #pragma surface surf Standard addshadow

		void surf(Input IN, inout SurfaceOutputStandard o){
			if (checkVisibility(IN.worldPos))discard;
			
			o.Albedo = _TopColor;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;

			half3 worldT = WorldNormalVector(IN, half3(1,0,0));
            half3 worldB = WorldNormalVector(IN, half3(0,1,0));
            half3 worldN = WorldNormalVector(IN, half3(0,0,1));
            half3x3 world2Tangent = half3x3(worldT, worldB, worldN);
			
            o.Normal = mul(world2Tangent, _PlaneNormal) ;
            
		}
		ENDCG

			// float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
            // screenUV *= float2(8,6);
			// float3 n = UnpackScaleNormal (tex2D (_BumpMap, screenUV), _BumpStrenght);
			// n = mul(world2Tangent, n);
		// * n

		Cull Back

		CGPROGRAM
        #pragma surface surf Standard addshadow 

		void surf(Input IN, inout SurfaceOutputStandard o) {
            if (checkVisibility(IN.worldPos)){
				discard;
			}

            o.Albedo = tex2D(_MainTex, IN.uv_MainTex) * _Color;
            o.Normal = UnpackScaleNormal(tex2D (_BumpMapInner, IN.uv_BumpMapInner), _BumpStrenghtInner);
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			
		}
		ENDCG

	}
}

