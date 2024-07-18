#define UI_EFFECT

sampler2D _ParamTex;

// Unpack float to low-precision [0-1] fixed4.
float4 UnpackToVec4(float value)
{
	const int PACKER_STEP = 64;
	const int PRECISION = PACKER_STEP - 1;
	float4 unpacked;

	unpacked.x = (value % PACKER_STEP) / PRECISION;
	value = floor(value / PACKER_STEP);

	unpacked.y = (value % PACKER_STEP) / PRECISION;
	value = floor(value / PACKER_STEP);

	unpacked.z = (value % PACKER_STEP) / PRECISION;
	value = floor(value / PACKER_STEP);

	unpacked.w = (value % PACKER_STEP) / PRECISION;
	return unpacked;
}

// Unpack float to low-precision [0-1] fixed3.
float3 UnpackToVec3(float value)
{
	const int PACKER_STEP = 256;
	const int PRECISION = PACKER_STEP - 1;
	float3 unpacked;

	unpacked.x = (value % (PACKER_STEP)) / (PACKER_STEP - 1);
	value = floor(value / (PACKER_STEP));

	unpacked.y = (value % PACKER_STEP) / (PACKER_STEP - 1);
	value = floor(value / PACKER_STEP);

	unpacked.z = (value % PACKER_STEP) / (PACKER_STEP - 1);
	return unpacked;
}

// Unpack float to low-precision [0-1] half2.
half2 UnpackToVec2(float value)
{
	const int PACKER_STEP = 4096;
	const int PRECISION = PACKER_STEP - 1;
	half2 unpacked;

	unpacked.x = (value % (PACKER_STEP)) / (PACKER_STEP - 1);
	value = floor(value / (PACKER_STEP));

	unpacked.y = (value % PACKER_STEP) / (PACKER_STEP - 1);
	return unpacked;
}

// Sample texture with blurring.
// * Fast: Sample texture with 3x3 kernel.
// * Medium: Sample texture with 5x5 kernel.
// * Detail: Sample texture with 7x7 kernel.
float4 Tex2DBlurring (sampler2D tex, half2 texcood, half2 blur, half4 mask)
{
	#if FASTBLUR && EX
	const int KERNEL_SIZE = 5;
	const float KERNEL_[5] = { 0.2486, 0.7046, 1.0, 0.7046, 0.2486};
	#elif MEDIUMBLUR && EX
	const int KERNEL_SIZE = 9;
	const float KERNEL_[9] = { 0.0438, 0.1719, 0.4566, 0.8204, 1.0, 0.8204, 0.4566, 0.1719, 0.0438};
	#elif DETAILBLUR && EX
	const int KERNEL_SIZE = 13;
	const float KERNEL_[13] = { 0.0438, 0.1138, 0.2486, 0.4566, 0.7046, 0.9141, 1.0, 0.9141, 0.7046, 0.4566, 0.2486, 0.1138, 0.0438};
	#elif FASTBLUR
	const int KERNEL_SIZE = 3;
	const float KERNEL_[3] = { 0.4566, 1.0, 0.4566};
	#elif MEDIUMBLUR
	const int KERNEL_SIZE = 5;
	const float KERNEL_[5] = { 0.2486, 0.7046, 1.0, 0.7046, 0.2486};
	#elif DETAILBLUR
	const int KERNEL_SIZE = 7;
	const float KERNEL_[7] = { 0.1719, 0.4566, 0.8204, 1.0, 0.8204, 0.4566, 0.1719};
	#else
	const int KERNEL_SIZE = 1;
	const float KERNEL_[1] = { 1.0 };
	#endif
	float4 o = 0;
	float sum = 0;
	float2 shift = 0;
	for(int x = 0; x < KERNEL_SIZE; x++)
	{
		shift.x = blur.x * (float(x) - KERNEL_SIZE/2);
		for(int y = 0; y < KERNEL_SIZE; y++)
		{
			shift.y = blur.y * (float(y) - KERNEL_SIZE/2);
			float2 uv = texcood + shift;
			float weight = KERNEL_[x] * KERNEL_[y];
			sum += weight;
			#if EX
			fixed masked = min(mask.x <= uv.x, uv.x <= mask.z) * min(mask.y <= uv.y, uv.y <= mask.w);
			o += lerp(fixed4(0.5, 0.5, 0.5, 0), tex2D(tex, uv), masked) * weight;
			#else
			o += tex2D(tex, uv) * weight;
			#endif
		}
	}
	return o / sum;
}

// 샤이니 이펙트
half4 ApplyShinyEffect(half4 color, half2 shinyParam)
{
	const float PARAM1_POS_X = 0.25; 
	const float PARAM2_POS_X = 0.75; 
	float normalizedPos = shinyParam.x;
	float4 param1 = tex2D(_ParamTex, float2(PARAM1_POS_X, shinyParam.y));
	float4 param2 = tex2D(_ParamTex, float2(PARAM2_POS_X, shinyParam.y));
	half location = param1.x * 2 - 0.5;
	float width = param1.y;
	float soft = param1.z;
	float brightness = param1.w;
	float gloss = param2.x;
	half normalized = 1 - saturate(abs((normalizedPos - location) / width));
	half shinePower = smoothstep(0, soft, normalized); // min, max, input -> 색을 부드럽게 그라데이션을 만들어준다.
	half3 reflectColor = lerp(float3(1,1,1), color.rgb, gloss); // a, b, input -> a와 b사이를 보간하여 input의 값이 a ~ b 사이의 위치하는 값을 도출

	color.rgb += color.a * (shinePower / 2) * brightness + reflectColor; // 알파값, 발광 강도, 밝기, 반사 색상 연산 적용
	
	return color;
}