
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

struct Record{
  float3 point;
  float3 normal;
  float t;
  int face;
  int mat;
  float3 color;
};

struct Object{
  int type;
  float3 position;
  float radius;
  int mat;
  float3 color;
};

struct Scene{
  float3 bg;
  int objects;
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

int seed1;
int seed2;

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

void set_face(struct ray r,float3 normal,struct Record *rec)
{
  rec->face = dot(r.direction,normal) < (float)0.0;

  if (rec->face) rec->normal = normal;
  else rec->normal = Smultif(-1.0,normal);
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

float3 sample_square(int x , int y)
{
  float3 r = {random(x,y)-0.5,random(x,y)-0.5,0};

  return r;
}

struct ray getray(int x, int y, struct Camera c, int i)
{

  float3 offset = sample_square(seed1+i,seed2+i*345);

  float3 pixel_sample = addf(c.pixel_location,addf(Smultif(x+offset.x,c.delta_u),Smultif((float)y+offset.y,c.delta_v)));

  float3 ray_direction = subf(pixel_sample,c.position);

  struct ray r;

  r.origin = c.position;
  r.direction = ray_direction;

  return r;

}

int hit_sphere(struct Object s,struct ray r, float tmin,float tmax,struct Record *rec)
{

  float3 oc = subf(s.position,r.origin);
  float a = dot(r.direction,r.direction);
  float b = dot(r.direction,oc);
  float c = dot(oc,oc) -(s.radius*s.radius);
  float d = b*b - a*c;
  float sd = sqrt(d);

  if (d<0) return 0;

  float rt = (b-sd)/a;
  if (rt <= tmin || tmax <= rt){
    rt = (b+sd)/a;
    if (rt<=tmin || tmax <=rt) return 0;
  }

  rec->t = rt;
  rec->point = get(rt,r);
  float3 normal = Sdividef(s.radius,subf(rec->point,s.position));
  set_face(r,normal,rec);
  rec->mat = s.mat;
  rec->color = s.color;

  return 1;
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

int near_zero(float3 a)
{
  const float threshold = 1e-8f;

  return fabs(a.x) < threshold && fabs(a.y) < threshold && fabs(a.z) < threshold;
}

float3 rand_u(int i)
{
  float3 randU = {random(seed1+i,seed2+i*345),random(seed2+i*345,seed1+i),random(seed1+i*345,seed2*i)};
  return randU;
}

float3 rand_in(int i)
{
  float3 t = {1.0,1.0,1.0};
  float3 p = subf(Smultif((float)10.0,rand_u(i)),t);
  int count = 0;

  while(length(p)*length(p) >= (float)2.0){
    p = subf(Smultif((float)2.0,rand_u(count+i)),t);
    count += 1;
  }

  return p;
}

int matte(struct ray r,struct Record rec,float3 *match, struct ray *scat,int i)
{
  float3 randU = rand_in(i);

  float3 target = addf(rec.normal,randU);

  float3 dir = addf(rec.normal,target);

  if (near_zero(dir)) dir = rec.normal;

  struct ray s = {rec.point,dir};

  *scat = s;
  *match = rec.color;

  return 1;
}

float3 reflect(float3 v, float3 u){
  return subf(v,Smultif((float)2.0*dot(v,u),u));
}

int metal(struct ray r,struct Record rec,float3 *match, struct ray *scat,int i){
  float3 ref = reflect(r.direction,rec.normal);
  struct ray s = {rec.point,ref};
  *scat = s;
  *match = rec.color;
   
  return 1;
}

float3 refract(float3 uv,float3 n,float et){
  float ct = fmin(dot(Smultif((float)-1.0,uv),n),(float)1.0);
  float3 r_out = Smultif(et,addf(uv,Smultif(ct,n)));
  float3 r_l = Smultif((float)-1.0*sqrt(fabs((float)1.0 - length(r_out)*length(r_out))),n);

  return addf(r_out,r_l);
}

float reflectance(float cos,float rid){
  float r0 = ((float)1.0 - rid)/((float)1.0 + rid);
  r0 = r0 * r0;
  return r0 + ((float)1.0 - r0)*pow((float)1.0-cos,5);
}

float ri = 1.50;

int glass(struct ray r,struct Record rec,float3 *match, struct ray *scat,int i){
  float3 cc = {1.0,1.0,1.0};
  *match = cc;
  float rid;

  if (rec.face) rid = 1.0/ri;
  else rid = ri;

  float3 ud = normalize(r.direction);
  float cos = fmin(dot(Smultif((float)-1.0,ud),rec.normal),(float)1.0);
  float sin = sqrt((float)1.0 - cos*cos);

  int cref = rid*sin > (float)1.0;
  float3 dir;
 
  if (cref || reflectance(cos,rid) > random(seed1+i,seed2+i*345)) dir = reflect(ud,rec.normal);
  else dir = refract(ud,rec.normal,rid);

  struct ray s = {rec.point,dir};
  *scat = s;

  return 1;
}

int material(struct ray r,struct Record rec,float3 *match, struct ray *scat,int i)
{
  if (rec.mat == 1) return matte(r,rec,match,scat,i);
  else if (rec.mat == 2) return metal(r,rec,match,scat,i);
  else if (rec.mat == 3) return glass(r,rec,match,scat,i);
}

int objects;

int hit_any_object(struct Object* scene,struct ray r, float tmin,struct Record *rec)
{
  struct Object s;
  struct Record re;
  int cont = 0;
  float tmax = INFINITY;
  float closest = tmax;

  for (int i = 0; i<objects;i++){
    s = scene[i];
    if (hit_sphere(s,r,tmin,closest,&re)){
      *rec = re;
      closest = re.t;
      cont = 1;
    }
  }
  return cont;
}

float3 ray_color(struct ray r,struct Object* scene,int max_depth,int i)
{
  float3 color = {1.0,1.0,1.0};
  float3 color2 = {0.0,0.0,0.0};
  int depth = 0;

  while (depth < max_depth){
    struct Record rec;

    if (hit_any_object(scene,r,0.001,&rec)){
      struct ray scat;
      float3 match;
    
      if(material(r,rec,&match,&scat,i+depth)){
        color = multif(color,match);
        r = scat;
        depth++;
      }else{
        return color2;
      }

    }else {
      return multif(color,background(r));  
    }

  }

  return color2;
}

/* MAIN FUNCTION */

__kernel void kernel_main(struct Camera c,struct Shader s,struct Palette p,struct Scene scene,__global float* output,float rs1,float rs2,__global struct Object* input)
{

  unsigned int work_item_id = get_global_id(0)*3;	/* the unique global id of the work item for current index*/
  int x = get_global_id(0) % c.width;	
  int y = get_global_id(0) / c.width;

  float time = (float)c.frames/(float)60.0;

  bgcolor = scene.bg;

  float3 color = {0.0,0.0,0.0};

  seed1 = x *c.frames% 1000 + (rs1*100);
  seed2 = y *c.frames% 1000 + (rs2*100);

  int samples = 100;
  float sample_scale = 1.0/(float)samples;

  objects = scene.objects;

  if (c.mode == 0){
    for (int i = 0;i<samples;i++){
      struct ray r = getray(x,y,c,i);

      color = addf(color,ray_color(r,input,50,i));
    }
    color = Smultif(sample_scale,color);

    /*color = shader(x,y,c.width,c.height,time,color);*/
    
  }

  if (c.mode == 1){
    color = shader(x,y,c.width,c.height,time,color);
  }

  if (c.mode == 2){
    p1 = p.p1;
    p2 = p.p2;
    p3 = p.p3;
    p4 = p.p4;
    color = shader1(x,y,c.width,c.height,time,s);
  }


  output[work_item_id] = sqrt(color.x);
  output[work_item_id+1] = sqrt(color.y);
  output[work_item_id+2] = sqrt(color.z);

}