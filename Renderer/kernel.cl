

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
    float fps;
};

struct ray{
    float3 origin;
    float3 direction;
};

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

float3 background(struct ray r)
{
  float3 ud = normalize(r.direction);

  float n = 0.5*(ud.y + 1.5);
  float xn = 1.0 - n;

  float3 color = {n*1.0,n*0.7,n*0.5};

  float3 xcolor = {xn*1.0,xn*1.0,xn*1.0};

  return addf(xcolor,color);
}

float3 pixelcolor(struct ray r)
{
  return background(r);
}

/*pallette that shader uses*/
float3 pallette(float t)
{

  float3 a = {0.5,0.5,0.5};
  float3 b = {0.5,0.5,0.5};
  float3 c = {1.0,1.0,1.0};
  float3 d = {0.363,0.516,0.757};

  float3 r = Smultif((float)6.28318,addf(Smultif(t,c),d));

  r.x = cos(r.x);
  r.y = cos(r.y);
  r.z = cos(r.z);

  r = addf(a,multif(r,b));

  return r;
}

float3 shader(int x, int y,int width, int height,float time){

  float3 fc = {0.0,0.0,0.0};

  /* x and y pos scales from -1 - 1*/
  float xv = ((((float)x/width)-0.5)*2.0)*((float)width/(float)height); 
  float yv = (((float)y/height)-0.5)*-2.0;
  
  /*sperating color and shape generation*/
  float xu = xv;
  float yu = yv;

  float2 u = {xu,yu};

  for (int i = 0;i<3;i++){
  
    /*creating shape of animation*/ 
    xv = (xv*1.0 - floor(xv*1.0)) -0.5;
    yv = (yv*1.0 - floor(yv*1.0)) - 0.5;

    float2 v = {xv,yv};

    /*pick the color using pallete, add time to it for more randomness*/
    float3 p = pallette(length(v)+time*0.7 + i*0.7);

    float lv = length(v) * exp(0.1*length(u));

    float l = fabs(sin(lv*8 + time)/8); 
    l = pow((float)0.01/ l, (float)1.5);

    float3 c = {l,l,l};

    /*combining shape and color*/
    c = multif(p,c);

    fc = addf(fc,c);
  }

  return fc;
}

float3 pallette1(float t)
{

  float3 a = {0.808, 0.628, 1.208};
  float3 b = {-0.442, -0.302, 0.318};
  float3 c = {3.138, 3.138, 3.138};
  float3 d = {1.068, 0.408, 0.988};

  float3 r = Smultif((float)6.28318,addf(Smultif(t,c),d));

  r.x = cos(r.x);
  r.y = cos(r.y);
  r.z = cos(r.z);

  r = addf(a,multif(r,b));

  return r;
}

float3 shader1(int x, int y,int width, int height,float time)
{
  float3 finalcolor = {0.0,0.0,0.0};

  /* x and y pos scales from -1 - 1*/
  float xv = ((((float)x/width)-0.5)*2.0)*((float)width/(float)height); 
  float yv = (((float)y/height)-0.5)*-2.0;
  
  /*sperating color and shape generation*/
  float xu = xv;
  float yu = yv;

  float2 u = {xu,yu};

  float glowfactor = 0.01;

  float pulsefactor = 7.0;

  float fractalfactor = 1.1;

  float colorfactor = 0.3;

  float freqfactor = 0.3;

  for (int i = 0; i < 5;i++){

    xv = (xv*fractalfactor - floor(xv*fractalfactor)) -0.5;
    yv = (yv*fractalfactor - floor(yv*fractalfactor)) - 0.5;

    float2 v = {xv,yv};

    float3 color = pallette1(length(u)+time*colorfactor + i*colorfactor);

    float sfactor = pow(glowfactor/(sin(length(v)*exp((float)freqfactor*length(u))*pulsefactor +time)/pulsefactor),(float)2.0);

    float3 shape = {sfactor,sfactor,sfactor};

    float3 combo = multif(color,shape);

    finalcolor = addf(finalcolor,combo);
  }

  return finalcolor;
}

__kernel void kernel_main(__constant float* input, struct Camera c,__global float* output)
{

  unsigned int work_item_id = get_global_id(0)*3;	/* the unique global id of the work item for current index*/
  int x = get_global_id(0) % c.width;	
  int y = get_global_id(0) / c.width;

  float time = (float)c.frames/(float)60.0;

  float3 color;

  if (c.mode == 0){
    struct ray r = getray(x,y,c);

    color = pixelcolor(r);
  }

  if (c.mode == 1){
    color = shader(x,y,c.width,c.height,time);
  }

  if (c.mode == 2){
    color = shader1(x,y,c.width,c.height,time);
  }


  output[work_item_id] = color.x;
  output[work_item_id+1] = color.y;
  output[work_item_id+2] = color.z;

}