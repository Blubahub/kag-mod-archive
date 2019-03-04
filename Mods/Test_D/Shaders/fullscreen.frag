uniform sampler2D baseMap;
varying vec2 Texcoord;

uniform float saturation;
uniform float coloringStrength;
uniform vec4  coloring;
uniform float sampleDist;
uniform float zoom;

// For all settings: 1.0 = 100% 0.5=50% 1.5 = 150%
vec4 ContrastSaturationBrightness(vec4 color, float brt, float sat, float con)
{
   // Increase or decrease theese values to adjust r, g and b color channels seperately
   const float AvgLumR = 0.5;
   const float AvgLumG = 0.5;
   const float AvgLumB = 0.5;
   
   const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);
   
   vec3 AvgLumin = vec3(AvgLumR, AvgLumG, AvgLumB);
   vec3 brtColor = vec3(color.r,color.g,color.b) * brt;
   vec3 intensity = vec3(dot(brtColor, LumCoeff));
   
   vec3 satColor = mix(intensity, vec3(color.r,color.g,color.b), sat);
   vec3 conColor = mix(AvgLumin, satColor, con);
   return vec4(conColor.r, conColor.g, conColor.b, 1.0);
}

void main()
{
   vec4 sample = texture2D(baseMap, Texcoord);
   vec4 avg = sample;
      
   if (sampleDist > 0.0)
   {

    vec2 samples[10];
    samples[0]  = Texcoord + sampleDist * vec2(-0.326212, -0.405805);
    samples[1]  = Texcoord + sampleDist * vec2(-0.840144, -0.073580);
    samples[2]  = Texcoord + sampleDist * vec2(-0.695914,  0.457137);
    samples[3]  = Texcoord + sampleDist * vec2(-0.203345,  0.620716);
    samples[4]  = Texcoord + sampleDist * vec2(0.962340, -0.194983);
    samples[5]  = Texcoord + sampleDist * vec2(0.473434, -0.480026);
    samples[6]  = Texcoord + sampleDist * vec2(0.519456,  0.767022);
    samples[7]  = Texcoord + sampleDist * vec2(0.185461, -0.893124);
    samples[8]  = Texcoord + sampleDist * vec2(0.507431,  0.064425);
    samples[9]  = Texcoord + sampleDist * vec2(0.896420,  0.412458);
   // samples[10]  = Texcoord + sampleDist * vec2(-0.321940, -0.932615);
   // samples[11]  = Texcoord + sampleDist * vec2(-0.791559, -0.597705);
    vec4 col;
   
    float brightcutoff = 2.45;
    float avglum = avg.r + avg.g + avg.b;
         
   // if (avglum < brightcutoff)
   // {
        // avg.r = avg.r - 0.73;
        // avg.g = avg.g - 0.73;
        // avg.b = avg.b - 0.73;
   // }
  
        for (int i = 0; i < 10; i++)
        {
            vec2 tC = min(vec2(0.999,0.999),max(vec2(0.001,0.001),samples[i]));
            col = texture2D(baseMap, tC );
         
            avglum = col.r + col.g + col.b;
         
          if (avglum > brightcutoff)
          {
             avg += col;
          }
        }
        avg /= 11.0;

   
    avg = sample + avg;
   
   }
   
  // float avglum = (avg.r + avg.g + avg.b)/4.0;
  // avglum = avglum + max(max(avg.r, avg.g), avg.b)*0.5;
  // avg = ContrastSaturationBrightness( avg, 2.0-avglum, avglum*3.0, 1.0);
   
   gl_FragColor = avg;
}
