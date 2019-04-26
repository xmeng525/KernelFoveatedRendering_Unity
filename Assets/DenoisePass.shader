Shader "Custom/DenoisePass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Pass2Tex ("Texture", 2D) = "white" {}
		_eyeX ("_eyeX", float) = 0.5
		_eyeY ("_eyeY", float) = 0.5
		_iResolutionX ("_iResolutionX", float) = 500
		_iResolutionY ("_iResolutionY", float) = 500
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

			float4 gausBlur5(sampler2D myTexture, float2 pos, float2 iResolution) // perform gaussian blur
			{
				//this will be our RGBA sum
				float2 pixel_size = float2(1.0,1.0) / iResolution.xy;
				float4 sum = float4(0.0f,0.0f,0.0f,0.0f);
				sum += tex2D(myTexture, pos + float2(-2,-2) * pixel_size) * 0.0165315806437010;
				sum += tex2D(myTexture, pos + float2(-2,-1) * pixel_size) * 0.0297018706890914;
				sum += tex2D(myTexture, pos + float2(-2, 0) * pixel_size) * 0.0361082918460354;
				sum += tex2D(myTexture, pos + float2(-2, 1) * pixel_size) * 0.0297018706890914;
				sum += tex2D(myTexture, pos + float2(-2, 2) * pixel_size) * 0.0165315806437010;

				sum += tex2D(myTexture, pos + float2(-1,-2) * pixel_size) * 0.0297018706890914;
				sum += tex2D(myTexture, pos + float2(-1,-1) * pixel_size) * 0.0533645960084072;
				sum += tex2D(myTexture, pos + float2(-1, 0) * pixel_size) * 0.0648748500418541;
				sum += tex2D(myTexture, pos + float2(-1, 1) * pixel_size) * 0.0533645960084072;
				sum += tex2D(myTexture, pos + float2(-1, 2) * pixel_size) * 0.0297018706890914;

				sum += tex2D(myTexture, pos + float2( 0,-2) * pixel_size) * 0.0361082918460354;
				sum += tex2D(myTexture, pos + float2( 0,-1) * pixel_size) * 0.0648748500418541;
				sum += tex2D(myTexture, pos + float2( 0, 0) * pixel_size) * 0.0788677603272776;
				sum += tex2D(myTexture, pos + float2( 0, 1) * pixel_size) * 0.0648748500418541;
				sum += tex2D(myTexture, pos + float2( 0, 2) * pixel_size) * 0.0361082918460354;

				sum += tex2D(myTexture, pos + float2( 1,-2) * pixel_size) * 0.0297018706890914;
				sum += tex2D(myTexture, pos + float2( 1,-1) * pixel_size) * 0.0533645960084072;
				sum += tex2D(myTexture, pos + float2( 1, 0) * pixel_size) * 0.0648748500418541;
				sum += tex2D(myTexture, pos + float2( 1, 1) * pixel_size) * 0.0533645960084072;
				sum += tex2D(myTexture, pos + float2( 1, 2) * pixel_size) * 0.0297018706890914;

				sum += tex2D(myTexture, pos + float2( 2,-2) * pixel_size) * 0.0165315806437010;
				sum += tex2D(myTexture, pos + float2( 2,-1) * pixel_size) * 0.0297018706890914;
				sum += tex2D(myTexture, pos + float2( 2, 0) * pixel_size) * 0.0361082918460354;
				sum += tex2D(myTexture, pos + float2( 2, 1) * pixel_size) * 0.0297018706890914;
				sum += tex2D(myTexture, pos + float2( 2, 2) * pixel_size) * 0.0165315806437010;
				return sum;
			}

			float4 gausBlur3(sampler2D myTexture, float2 pos, float2 iResolution) // perform gaussian blur
			{
				//this will be our RGBA sum
				float2 pixel_size = float2(1.0,1.0) / iResolution.xy;
				float4 sum = float4(0.0f,0.0f,0.0f,0.0f);
				sum += tex2D(myTexture, pos + float2(-1,-1) * pixel_size) * 0.0751;
				sum += tex2D(myTexture, pos + float2(-1, 0) * pixel_size) * 0.1238;
				sum += tex2D(myTexture, pos + float2(-1, 1) * pixel_size) * 0.0751;
				sum += tex2D(myTexture, pos + float2( 0,-1) * pixel_size) * 0.1238;
				sum += tex2D(myTexture, pos + float2( 0, 0) * pixel_size) * 0.2042;
				sum += tex2D(myTexture, pos + float2( 0, 1) * pixel_size) * 0.1238;
				sum += tex2D(myTexture, pos + float2( 1,-1) * pixel_size) * 0.0751;
				sum += tex2D(myTexture, pos + float2( 1, 0) * pixel_size) * 0.1238;
				sum += tex2D(myTexture, pos + float2( 1, 1) * pixel_size) * 0.0751;
				return sum;
			}

			float4 gausBlur11(sampler2D myTexture, float2 pos, float2 iResolution){
				float2 pixel_size = float2(1.0,1.0) / iResolution.xy;
				float4 sum = float4(0.0f,0.0f,0.0f,0.0f);
				sum += tex2D(myTexture, pos + float2(-5,-5) * pixel_size) * 0.007959;
				sum += tex2D(myTexture, pos + float2(-5,-4) * pixel_size) * 0.008049;
				sum += tex2D(myTexture, pos + float2(-5,-3) * pixel_size) * 0.008120;
				sum += tex2D(myTexture, pos + float2(-5,-2) * pixel_size) * 0.008171;
				sum += tex2D(myTexture, pos + float2(-5,-1) * pixel_size) * 0.008202;
				sum += tex2D(myTexture, pos + float2(-5, 0) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2(-5, 1) * pixel_size) * 0.008202;
				sum += tex2D(myTexture, pos + float2(-5, 2) * pixel_size) * 0.008171;
				sum += tex2D(myTexture, pos + float2(-5, 3) * pixel_size) * 0.008120;
				sum += tex2D(myTexture, pos + float2(-5, 4) * pixel_size) * 0.008049;
				sum += tex2D(myTexture, pos + float2(-5, 5) * pixel_size) * 0.007959;
				sum += tex2D(myTexture, pos + float2(-4,-5) * pixel_size) * 0.008049;
				sum += tex2D(myTexture, pos + float2(-4,-4) * pixel_size) * 0.008140;
				sum += tex2D(myTexture, pos + float2(-4,-3) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2(-4,-2) * pixel_size) * 0.008263;
				sum += tex2D(myTexture, pos + float2(-4,-1) * pixel_size) * 0.008295;
				sum += tex2D(myTexture, pos + float2(-4, 0) * pixel_size) * 0.008305;
				sum += tex2D(myTexture, pos + float2(-4, 1) * pixel_size) * 0.008295;
				sum += tex2D(myTexture, pos + float2(-4, 2) * pixel_size) * 0.008263;
				sum += tex2D(myTexture, pos + float2(-4, 3) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2(-4, 4) * pixel_size) * 0.008140;
				sum += tex2D(myTexture, pos + float2(-4, 5) * pixel_size) * 0.008049;
				sum += tex2D(myTexture, pos + float2(-3,-5) * pixel_size) * 0.008120;
				sum += tex2D(myTexture, pos + float2(-3,-4) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2(-3,-3) * pixel_size) * 0.008284;
				sum += tex2D(myTexture, pos + float2(-3,-2) * pixel_size) * 0.008336;
				sum += tex2D(myTexture, pos + float2(-3,-1) * pixel_size) * 0.008367;
				sum += tex2D(myTexture, pos + float2(-3, 0) * pixel_size) * 0.008378;
				sum += tex2D(myTexture, pos + float2(-3, 1) * pixel_size) * 0.008367;
				sum += tex2D(myTexture, pos + float2(-3, 2) * pixel_size) * 0.008336;
				sum += tex2D(myTexture, pos + float2(-3, 3) * pixel_size) * 0.008284;
				sum += tex2D(myTexture, pos + float2(-3, 4) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2(-3, 5) * pixel_size) * 0.008120;
				sum += tex2D(myTexture, pos + float2(-2,-5) * pixel_size) * 0.008171;
				sum += tex2D(myTexture, pos + float2(-2,-4) * pixel_size) * 0.008263;
				sum += tex2D(myTexture, pos + float2(-2,-3) * pixel_size) * 0.008336;
				sum += tex2D(myTexture, pos + float2(-2,-2) * pixel_size) * 0.008388;
				sum += tex2D(myTexture, pos + float2(-2,-1) * pixel_size) * 0.008420;
				sum += tex2D(myTexture, pos + float2(-2, 0) * pixel_size) * 0.008430;
				sum += tex2D(myTexture, pos + float2(-2, 1) * pixel_size) * 0.008420;
				sum += tex2D(myTexture, pos + float2(-2, 2) * pixel_size) * 0.008388;
				sum += tex2D(myTexture, pos + float2(-2, 3) * pixel_size) * 0.008336;
				sum += tex2D(myTexture, pos + float2(-2, 4) * pixel_size) * 0.008263;
				sum += tex2D(myTexture, pos + float2(-2, 5) * pixel_size) * 0.008171;
				sum += tex2D(myTexture, pos + float2(-1,-5) * pixel_size) * 0.008202;
				sum += tex2D(myTexture, pos + float2(-1,-4) * pixel_size) * 0.008295;
				sum += tex2D(myTexture, pos + float2(-1,-3) * pixel_size) * 0.008367;
				sum += tex2D(myTexture, pos + float2(-1,-2) * pixel_size) * 0.008420;
				sum += tex2D(myTexture, pos + float2(-1,-1) * pixel_size) * 0.008451;
				sum += tex2D(myTexture, pos + float2(-1, 0) * pixel_size) * 0.008462;
				sum += tex2D(myTexture, pos + float2(-1, 1) * pixel_size) * 0.008451;
				sum += tex2D(myTexture, pos + float2(-1, 2) * pixel_size) * 0.008420;
				sum += tex2D(myTexture, pos + float2(-1, 3) * pixel_size) * 0.008367;
				sum += tex2D(myTexture, pos + float2(-1, 4) * pixel_size) * 0.008295;
				sum += tex2D(myTexture, pos + float2(-1, 5) * pixel_size) * 0.008202;
				sum += tex2D(myTexture, pos + float2( 0,-5) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2( 0,-4) * pixel_size) * 0.008305;
				sum += tex2D(myTexture, pos + float2( 0,-3) * pixel_size) * 0.008378;
				sum += tex2D(myTexture, pos + float2( 0,-2) * pixel_size) * 0.008430;
				sum += tex2D(myTexture, pos + float2( 0,-1) * pixel_size) * 0.008462;
				sum += tex2D(myTexture, pos + float2( 0, 0) * pixel_size) * 0.008473;
				sum += tex2D(myTexture, pos + float2( 0, 1) * pixel_size) * 0.008462;
				sum += tex2D(myTexture, pos + float2( 0, 2) * pixel_size) * 0.008430;
				sum += tex2D(myTexture, pos + float2( 0, 3) * pixel_size) * 0.008378;
				sum += tex2D(myTexture, pos + float2( 0, 4) * pixel_size) * 0.008305;
				sum += tex2D(myTexture, pos + float2( 0, 5) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2( 1,-5) * pixel_size) * 0.008202;
				sum += tex2D(myTexture, pos + float2( 1,-4) * pixel_size) * 0.008295;
				sum += tex2D(myTexture, pos + float2( 1,-3) * pixel_size) * 0.008367;
				sum += tex2D(myTexture, pos + float2( 1,-2) * pixel_size) * 0.008420;
				sum += tex2D(myTexture, pos + float2( 1,-1) * pixel_size) * 0.008451;
				sum += tex2D(myTexture, pos + float2( 1, 0) * pixel_size) * 0.008462;
				sum += tex2D(myTexture, pos + float2( 1, 1) * pixel_size) * 0.008451;
				sum += tex2D(myTexture, pos + float2( 1, 2) * pixel_size) * 0.008420;
				sum += tex2D(myTexture, pos + float2( 1, 3) * pixel_size) * 0.008367;
				sum += tex2D(myTexture, pos + float2( 1, 4) * pixel_size) * 0.008295;
				sum += tex2D(myTexture, pos + float2( 1, 5) * pixel_size) * 0.008202;
				sum += tex2D(myTexture, pos + float2( 2,-5) * pixel_size) * 0.008171;
				sum += tex2D(myTexture, pos + float2( 2,-4) * pixel_size) * 0.008263;
				sum += tex2D(myTexture, pos + float2( 2,-3) * pixel_size) * 0.008336;
				sum += tex2D(myTexture, pos + float2( 2,-2) * pixel_size) * 0.008388;
				sum += tex2D(myTexture, pos + float2( 2,-1) * pixel_size) * 0.008420;
				sum += tex2D(myTexture, pos + float2( 2, 0) * pixel_size) * 0.008430;
				sum += tex2D(myTexture, pos + float2( 2, 1) * pixel_size) * 0.008420;
				sum += tex2D(myTexture, pos + float2( 2, 2) * pixel_size) * 0.008388;
				sum += tex2D(myTexture, pos + float2( 2, 3) * pixel_size) * 0.008336;
				sum += tex2D(myTexture, pos + float2( 2, 4) * pixel_size) * 0.008263;
				sum += tex2D(myTexture, pos + float2( 2, 5) * pixel_size) * 0.008171;
				sum += tex2D(myTexture, pos + float2( 3,-5) * pixel_size) * 0.008120;
				sum += tex2D(myTexture, pos + float2( 3,-4) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2( 3,-3) * pixel_size) * 0.008284;
				sum += tex2D(myTexture, pos + float2( 3,-2) * pixel_size) * 0.008336;
				sum += tex2D(myTexture, pos + float2( 3,-1) * pixel_size) * 0.008367;
				sum += tex2D(myTexture, pos + float2( 3, 0) * pixel_size) * 0.008378;
				sum += tex2D(myTexture, pos + float2( 3, 1) * pixel_size) * 0.008367;
				sum += tex2D(myTexture, pos + float2( 3, 2) * pixel_size) * 0.008336;
				sum += tex2D(myTexture, pos + float2( 3, 3) * pixel_size) * 0.008284;
				sum += tex2D(myTexture, pos + float2( 3, 4) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2( 3, 5) * pixel_size) * 0.008120;
				sum += tex2D(myTexture, pos + float2( 4,-5) * pixel_size) * 0.008049;
				sum += tex2D(myTexture, pos + float2( 4,-4) * pixel_size) * 0.008140;
				sum += tex2D(myTexture, pos + float2( 4,-3) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2( 4,-2) * pixel_size) * 0.008263;
				sum += tex2D(myTexture, pos + float2( 4,-1) * pixel_size) * 0.008295;
				sum += tex2D(myTexture, pos + float2( 4, 0) * pixel_size) * 0.008305;
				sum += tex2D(myTexture, pos + float2( 4, 1) * pixel_size) * 0.008295;
				sum += tex2D(myTexture, pos + float2( 4, 2) * pixel_size) * 0.008263;
				sum += tex2D(myTexture, pos + float2( 4, 3) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2( 4, 4) * pixel_size) * 0.008140;
				sum += tex2D(myTexture, pos + float2( 4, 5) * pixel_size) * 0.008049;
				sum += tex2D(myTexture, pos + float2( 5,-5) * pixel_size) * 0.007959;
				sum += tex2D(myTexture, pos + float2( 5,-4) * pixel_size) * 0.008049;
				sum += tex2D(myTexture, pos + float2( 5,-3) * pixel_size) * 0.008120;
				sum += tex2D(myTexture, pos + float2( 5,-2) * pixel_size) * 0.008171;
				sum += tex2D(myTexture, pos + float2( 5,-1) * pixel_size) * 0.008202;
				sum += tex2D(myTexture, pos + float2( 5, 0) * pixel_size) * 0.008212;
				sum += tex2D(myTexture, pos + float2( 5, 1) * pixel_size) * 0.008202;
				sum += tex2D(myTexture, pos + float2( 5, 2) * pixel_size) * 0.008171;
				sum += tex2D(myTexture, pos + float2( 5, 3) * pixel_size) * 0.008120;
				sum += tex2D(myTexture, pos + float2( 5, 4) * pixel_size) * 0.008049;
				sum += tex2D(myTexture, pos + float2( 5, 5) * pixel_size) * 0.007959;
				return sum;
			}

			sampler2D _MainTex;
			sampler2D _Pass2Tex;
			uniform float _iResolutionX;
			uniform float _iResolutionY;
			uniform float _eyeX;
			uniform float _eyeY;
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col;
				float2 iResolution = float2(_iResolutionX, _iResolutionY);
				float dist = length(i.uv - float2(_eyeX, _eyeY));
				if (dist < 0.2)
					col = tex2D(_Pass2Tex, i.uv);
				else if (dist < 0.25)
					col = gausBlur3(_Pass2Tex, i.uv, iResolution);
				else if (dist < 0.35)
					col = gausBlur5(_Pass2Tex, i.uv, iResolution);
				else
					col = gausBlur11(_Pass2Tex, i.uv, iResolution);
				//col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
