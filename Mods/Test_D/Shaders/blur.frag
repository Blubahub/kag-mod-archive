uniform sampler2D baseMap;
uniform sampler2D extraMap;

varying vec2 Texcoord;

uniform float amount;
uniform float res_x;
uniform float res_y;
uniform float time;

void main()
{
	vec4 sample = texture2D(baseMap, Texcoord);
	if (amount <= 0.0001)
	{
		gl_FragColor = vec4(sample.rgb, 1.0);
	}
	else //apply blur
	{
		vec4 avg = sample;

		//first sample
		float scale = 1000.0;

		vec2 noisepos = vec2(Texcoord.x * scale / res_x + time * 0.937, Texcoord.y * scale / res_y + time * 0.33);
		vec4 noisea = (texture2D(extraMap, noisepos) - vec4(0.5, 0.5, 0.5, 0.5)) * 2.0;

		noisepos = vec2(Texcoord.x * scale / res_x - time * 0.523, Texcoord.y * scale / res_y - time * 0.733);
		vec4 noiseb = (texture2D(extraMap, noisepos) - vec4(0.5, 0.5, 0.5, 0.5)) * 2.0;

		vec4 noise = noisea + noiseb;

		vec2 noiseoffset = Texcoord + vec2(noise.g / res_x, noise.b / res_y) * amount;

		avg -= abs(noise * 0.1);

		float sampleDist = abs(amount + noise.r * 0.7);

		float off_x = 1.0 / res_x;
		float off_y = 1.0 / res_y;

		float c_off_x = 0.70710678 / res_x;
		float c_off_y = 0.70710678 / res_y;

		vec2 samples[8];
		//ortho offsets
		samples[0] = noiseoffset + sampleDist * vec2(-off_x,  0.0);
		samples[1] = noiseoffset + sampleDist * vec2(off_x,  0.0);
		samples[2] = noiseoffset + sampleDist * vec2(0.0, -off_y);
		samples[3] = noiseoffset + sampleDist * vec2(0.0,  off_y);
		//corner offsets
		samples[4] = noiseoffset + sampleDist * vec2(-c_off_x,  c_off_y);
		samples[5] = noiseoffset + sampleDist * vec2(c_off_x,  c_off_y);
		samples[6] = noiseoffset + sampleDist * vec2(c_off_x, -c_off_y);
		samples[7] = noiseoffset + sampleDist * vec2(-c_off_x, -c_off_y);

		for (int i = 0; i < 8; i++)
		{
			vec2 tC = min(vec2(0.9999, 0.9999), max(vec2(0.0001, 0.0001), samples[i]));
			avg += texture2D(baseMap, tC);
		}
		avg /= 9.0;

		gl_FragColor = vec4(avg.rgb, 1.0);
	}
}
