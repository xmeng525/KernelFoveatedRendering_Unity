Shader "Custom/Pass1"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_iResolutionX ("_iResolutionX", float) = 500
		_iResolutionY ("_iResolutionY", float) = 500
		_eyeX ("_eyeX", float) = 0.5
		_eyeY ("_eyeY", float) = 0.5
		_scaleRatio ("_scaleRatio", float) = 2.0
		_kernel ("_kernel", float) = 1.0
		_iApplyLogMap1 ("_iApplyLogMap1", int) = 1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			uniform float _iResolutionX;
			uniform float _iResolutionY;
			uniform float _eyeX;
			uniform float _eyeY;
			uniform float _scaleRatio;
			uniform float _kernel;
			uniform int _iApplyLogMap1;
			float powInvFunc(float lr, float kernel)
			{
				float param = 1.0f / kernel;
				return pow(lr, param);
			}
			fixed4 frag (v2f i) : SV_Target
			{
				float2 iResolution = float2(_iResolutionX, _iResolutionY);
				float2 cursorPos = float2(_eyeX * 2.0 - 1.0, _eyeY * 2.0 - 1.0);
				float maxr = max(
					max(
						length((float2( 1.0, 1.0) - cursorPos.xy) * iResolution.xy), 
						length((float2( 1.0,-1.0) - cursorPos.xy) * iResolution.xy)
						),
					max(length((float2(-1.0, 1.0) - cursorPos.xy) * iResolution.xy), 
						length((float2(-1.0,-1.0) - cursorPos.xy) * iResolution.xy)
						)
					);
				float maxLr = log(maxr * 0.5);
				float maxTheta = 6.28318530718f;

				float2 tc = _scaleRatio * i.uv;
				tc.x = powInvFunc(tc.x, _kernel);

				float x = exp(tc.x * maxLr) * cos(tc.y * maxTheta);
				float y = exp(tc.x * maxLr) * sin(tc.y * maxTheta);

				float2 pq = float2(x,y) + (cursorPos + 1.0) * 0.5 * iResolution.xy; //[0, iReso.x]
				float2 newCoord = (_iApplyLogMap1 > 0) ? pq / iResolution : i.uv;

				fixed4 col = tex2D(_MainTex, newCoord);
				
				return col;
			}
			ENDCG
		}
	}
}
