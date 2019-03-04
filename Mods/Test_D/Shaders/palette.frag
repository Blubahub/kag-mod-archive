uniform sampler2D baseMap;
uniform sampler2D extraMap;
varying vec2 Texcoord;
uniform float res_x;
uniform float res_y;
uniform float scroll_x;
uniform float tick;

float dither(vec2 position)
{
	float val = floor( (mod(floor(position.x / 4.0) + position.y, 3.0) / 3.0) + 0.5 );
	return val == 0.0 ? -0.25 : val * 0.5;
}


void main()
{
	vec4 sample = texture2D(baseMap, Texcoord);
	vec2 npos = vec2(floor(Texcoord.x * res_x + scroll_x), floor(Texcoord.y * res_y));
	float rawnoise = 0.5; //dither(npos);
	float n = (rawnoise - 0.5) * 8.0 / 256.0;
	sample = clamp(sample + n, 0.0, 1.0);
	sample = sample * (254.0 / 256.0) + vec4(1.0 / 256.0);
	sample.a = 1.0;

	//gl_FragColor = vec4(rawnoise, rawnoise, rawnoise, 1.0);
	//return;

	float cell = floor(sample.b * 16.0);

	vec2 lut_texel = vec2((sample.r + mod(cell, 4.0)), (sample.g + floor(cell / 4.0))) * 0.25;

	gl_FragColor = texture2D(extraMap, lut_texel);
}
