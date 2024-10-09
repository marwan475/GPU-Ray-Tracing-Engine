
/* STRUCTS */

struct Camera{
    int width;
    int height;
    float aspect_ratio;
    float viewport_h;
    float viewport_w;
    float focal_length;
    float3 position;
    float3 viewport_u;
    float3 viewport_v;
    float fov;   
    float3 look;
    float3 vup;
    float3 du,dv,dw;
    float3 delta_u;
    float3 delta_v;
    float3 vp_upperleft;
    float3 pixel_location;
    int mode;
    int frames;
};

struct ray{
    float3 origin;
    float3 direction;
};

struct Shader{
  float glowfactor;
  float pulsefactor;
  float fractalfactor;
  float colorfactor;
  float freqfactor;
  float fractalvariance;
  int iterations;
  float3 tint;
  int pal;
  float cfractalfactor ;
  int sfractal;
  int cfractal;
  float t;
  float sinf;
  float structf;
};

struct Palette{
  float3 p1;
  float3 p2;
  float3 p3;
  float3 p4; 
};

struct Scene{
  float3 bg;
};

/* GENERAL USE FUNCTIONS */

float3 addf(float3 a, float3 b)
{
    float3 r;

    r.x = a.x +b.x;
    r.y = a.y + b.y;
    r.z = a.z + b.z;

    return r;
}

float3 subf(float3 a, float3 b)
{
    float3 r;

    r.x = a.x - b.x;
    r.y = a.y - b.y;
    r.z = a.z - b.z;

    return r;
}

float3 multif(float3 a, float3 b)
{
    float3 r;

    r.x = a.x * b.x;
    r.y = a.y * b.y;
    r.z = a.z * b.z;

    return r;
}

float3 dividef(float3 a, float3 b)
{
    float3 r;

    r.x = a.x / b.x;
    r.y = a.y / b.y;
    r.z = a.z / b.z;

    return r;
}

float3 Smultif(float a, float3 b)
{
    float3 r;

    r.x = a * b.x;
    r.y = a * b.y;
    r.z = a * b.z;

    return r;
}

float3 Sdividef(float b, float3 a)
{
    float3 r;

    r.x = a.x / b;
    r.y = a.y / b;
    r.z = a.z / b;

    return r;
}

float3 fabs3(float3 f)
{
  float3 r;

  r.x = fabs(f.x);
  r.y = fabs(f.y);
  r.z = fabs(f.z);

  return r;

}

float3 get(float n, struct ray r)
{
  float3 a;
  float3 b;

  a.x = n*r.direction.x;
  a.y = n*r.direction.y;
  a.z = n*r.direction.z;

  b.x = r.origin.x + a.x;
  b.y = r.origin.y + a.y;
  b.z = r.origin.z + a.z;

  return b;
  
}

float random(int s0, int s1) {
	
    union {
		float f;
		int ui;
	} r;
    
    s0 = 36969 * ((s0) & 65535) + ((s0) >> 16);  
	s1 = 18000 * ((s1) & 65535) + ((s1) >> 16);

	int ir = ((s0) << 16) + (s1);

	r.ui = (ir & 0x007fffff) | 0x40000000;  
	return (r.f - 2.0f) / 2.0f;
}

/* SHADER CODE */

float3 p1;
float3 p2;
float3 p3;
float3 p4;


/*pallette that shader uses*/
float3 pallette(float t)
{

  float3 a = p1;
  float3 b = p2;
  float3 c = p3;
  float3 d = p4;

  float3 r = Smultif((float)6.28318,addf(Smultif(t,c),d));

  r.x = cos(r.x);
  r.y = cos(r.y);
  r.z = cos(r.z);

  r = addf(a,multif(r,b));

  return r;
}

float3 shader(int x, int y,int width, int height,float time, float3 color){

  float3 fc = color;

  /* x and y pos scales from -1 - 1*/
  float xv = ((((float)x/width)-0.5)*2.0)*((float)width/(float)height); 
  float yv = (((float)y/height)-0.5)*-2.0;
  
  /*sperating color and shape generation*/
  float xu = xv;
  float yu = yv;

  float2 u = {xu,yu};

  float frequency = 10.0;
  float amplitude = 1.0;

  float ripple = sin((yv + time) * frequency) * amplitude;

  fc = Smultif(((float)1.0 + ripple / (float)100.0),fc);

  return fc;
}

float circle(float2 uv,float r)
{
  return length(uv) - r;
}

float3 shader1(int x, int y,int width, int height,float time,struct Shader s)
{
  float3 finalcolor = {0.0,0.0,0.0};

  /* x and y pos scales from -1 - 1*/
  float xv = ((((float)x/width)-0.5)*2.0)*((float)width/(float)height); 
  float yv = (((float)y/height)-0.5)*-2.0;
  
  /*sperating color and shape generation*/
  float xu = xv;
  float yu = yv;

  float glowfactor = s.glowfactor;

  float pulsefactor = s.pulsefactor;

  float fractalfactor = s.fractalfactor;

  float colorfactor = s.colorfactor;

  float freqfactor = s.freqfactor;

  float fractalvariance = s.fractalvariance;

  int iterations = s.iterations;

  float3 tint = {1.0,1.0,1.0};

  int pal = s.pal;

  float cfractalfactor = s.cfractalfactor;

  int sfractal = s.sfractal;

  int cfractal = s.cfractal;

  float t = s.t;

  float sinf = s.sinf;

  float structf = s.structf; 

  for (int i = 0; i < iterations;i++){

    if (sfractal){
      xv = (xv*fractalfactor - floor(xv*fractalfactor)) -0.5;
      yv = (yv*fractalfactor - floor(yv*fractalfactor)) - 0.5;
    }

    if (cfractal){
      xu = (xu*cfractalfactor - floor(xu*cfractalfactor)) -0.5;
      yu = (yu*cfractalfactor - floor(yu*cfractalfactor)) - 0.5;
    }

    float2 u = {xu,yu};

    float2 v = {xv,yv};

    float3 color = tint;

    float colorstruct = circle(u,(float)0.0);

    if (pal >= 1)color = multif(tint,pallette(colorstruct+time*colorfactor*t + i*colorfactor*t));

    float structure = circle(v,(float)0.0);

    float sfactor = pow(glowfactor/(sin(structure*exp((float)freqfactor*length(u))*pulsefactor +time*t)/pulsefactor)*sinf + (structure*structf),(float)fractalvariance);

    float3 shape = {sfactor,sfactor,sfactor};

    float3 combo = multif(color,shape);

    finalcolor = addf(finalcolor,combo);
  }

  return finalcolor;
}

/* RAY TRACER CODE*/

struct ray getray(int x, int y, struct Camera c)
{
  float3 center = addf(c.pixel_location,addf(Smultif((float)x,c.delta_u),Smultif((float)y,c.delta_v)));

  float3 ray_direction = subf(center,c.position);

  length(center);

  struct ray r;

  r.origin = c.position;
  r.direction = ray_direction;

  return r;

}

float3 bgcolor;

float3 background(struct ray r)
{
  float3 ud = normalize(r.direction);

  float n = 0.5*(ud.y + 1.5);
  float xn = 1.0 - n;

  float3 color = {n*bgcolor.x,n*bgcolor.y,n*bgcolor.z};

  float3 xcolor = {xn*1.0,xn*1.0,xn*1.0};

  return addf(xcolor,color);
}

float3 pixelcolor(struct ray r)
{
  return background(r);
}

/* MAIN FUNCTION */

__kernel void kernel_main(__constant float* input, struct Camera c,struct Shader s,struct Palette p,struct Scene scene,__global float* output)
{

  unsigned int work_item_id = get_global_id(0)*3;	/* the unique global id of the work item for current index*/
  int x = get_global_id(0) % c.width;	
  int y = get_global_id(0) / c.width;

  float time = (float)c.frames/(float)60.0;

  bgcolor = scene.bg;

  float3 color = {1.0,1.0,1.0};

  if (c.mode == 0){
    struct ray r = getray(x,y,c);

    color = pixelcolor(r);

    /*color = shader(x,y,c.width,c.height,time,color);*/
    
  }

  if (c.mode == 1){
    color = shader(x,y,c.width,c.height,time,color);
  }

  if (c.mode == 2){
    color = shader1(x,y,c.width,c.height,time,s);
    p1 = p.p1;
    p2 = p.p2;
    p3 = p.p3;
    p4 = p.p4;
  }


  output[work_item_id] = color.x;
  output[work_item_id+1] = color.y;
  output[work_item_id+2] = color.z;

}