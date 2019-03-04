uniform sampler2D baseMap;
varying vec2 Texcoord;
uniform float amount;

void main() 
{
    vec4 colour = vec4(1.0);

    colour.r = texture2D(baseMap, Texcoord+vec2(amount, 0)).r;
    colour.g = texture2D(baseMap, Texcoord+vec2(0, amount)).g;
    colour.b = texture2D(baseMap, Texcoord).b;

    gl_FragColor = colour;
}