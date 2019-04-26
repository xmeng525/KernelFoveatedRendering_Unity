Shader "Custom/Pass2"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LogTex ("Texture", 2D) = "white" {}
		_iResolutionX ("_iResolutionX", float) = 500
		_iResolutionY ("_iResolutionY", float) = 500
		_eyeX ("_eyeX", float) = 0.5
		_eyeY ("_eyeY", float) = 0.5
		_scaleRatio ("_scaleRatio", float) = 2.0
		_kernel ("_kernel", float) = 1.0
		_iApplyLogMap2 ("_iApplyLogMap2", int) = 1
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
			sampler2D _LogTex;
			uniform float _iResolutionX;
			uniform float _iResolutionY;
			uniform float _eyeX;
			uniform float _eyeY;
			uniform float _scaleRatio;
			uniform float _kernel;
			uniform int _iApplyLogMap2;
			float powFunc(float lr, float kernel)
			{
				return pow(lr, kernel);
			}

			float4 cuttingLineBlur(sampler2D tex, float2 coord, float iRatio)
			{
				float epsilon = 1.0 / (_iResolutionX * iRatio);
				float4 tmpFragColor = float4(0.0, 0.0, 0.0, 0.0);
				if( 
					(iRatio > 2.5) && 
					(
						(coord.y < epsilon) || 
						(coord.y > 1.0/iRatio - epsilon)
					)
				)
				{
					tmpFragColor = (
									 tex2D(tex, float2(coord.x, 0.0)) +
									 tex2D(tex, float2(coord.x, 1.0 / iRatio)) 
								   ) / 2.0;
					return tmpFragColor;
				}
				return tex2D(tex, coord);
			}

			fixed4 frag (v2f i) : SV_Target
			{
				if (_scaleRatio < 1.0)
				{
					if (length(i.uv - float2(0.5, 0.5)) < 0.005)
						return float4(1.0, 1.0, 1.0, 0.0);
					else
						return tex2D(_LogTex, i.uv);
				}
					
				float2 tc = i.uv;
				float2 iResolution = float2(_iResolutionX, _iResolutionY);
				float2 cursorPos = float2(_eyeX * 2.0 - 1.0, _eyeY * 2.0 - 1.0);
				//apply blurring, using log-polar mapping
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

				float2 pq = tc * 2.0 - 1.0 - cursorPos; // normalize texture coordinate from [0,1] -> [-1, 1]
				float lr = log(length(pq * iResolution * 0.5f)); // get the lr of current pixel

				float theta = atan2(pq.y, pq.x) + step(pq.y, 0.0) * maxTheta; // get the angle of current pixel
				theta /= maxTheta; // normalize the angle
				
				//lr = lr / maxLr;
				lr = powFunc(lr / maxLr, _kernel); // normalize lr and kernel it
				
				float2 newCoord = float2(lr, theta) / _scaleRatio; // normalize the new texture coordinate to the scaleRatio
				float2 uv = (_iApplyLogMap2 > 0) ? newCoord : i.uv;
				float4 col = cuttingLineBlur(_LogTex, uv, _scaleRatio);
				fixed4 newColor;
				if (length(i.uv - float2(_eyeX, _eyeY)) < 0.003)
					newColor = float4(1.0, 0.0, 0.0, 0.0);
				else
					newColor = col;
				return newColor;
			}
			ENDCG
		}
	}
}
