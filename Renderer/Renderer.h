#ifndef RENDERER_H
#define RENDERER_H

#include <cl.hpp>
#include <vector>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>
#include <math.h>
#include <utility.h>
#include <string.h>

using namespace cl;

using std::vector;
using std::string;
using std::ifstream;

extern Platform pform;
extern vector<Platform> pforms; // list of all platforms available 
extern Device device;
extern vector<Device> devices; // list of all device on chosen platform
extern Context context; // OpenCl context
extern CommandQueue queue; // Command Queue
extern const char* kernel_s; // will contain our kernal source code
extern Program program;
extern Kernel kernel;

#define MAX_OBJECTS 100

struct Camera{
    int width;
    int height;
    float aspect_ratio;
    float viewport_h;
    float viewport_w;
    float focal_length;
    cl_float3 position;
    cl_float3 viewport_u;
    cl_float3 viewport_v;
    float fov;   
    cl_float3 look;
    cl_float3 vup;
    cl_float3 du,dv,dw;
    cl_float3 delta_u;
    cl_float3 delta_v;
    cl_float3 vp_upperleft;
    cl_float3 pixel_location;
    int mode;
    int frames;
};

struct Shader{
  cl_float glowfactor = 1.0;
  cl_float pulsefactor = 1.0;
  cl_float fractalfactor = 1.0;
  cl_float colorfactor = 1.0;
  cl_float freqfactor = 1.0;
  cl_float fractalvariance = 1.0;
  int iterations = 1;
  cl_float3 tint = {1.0,1.0,1.0};
  int pal = 0;
  cl_float cfractalfactor = 1.0;
  int sfractal = 0;
  int cfractal = 0;
  cl_float t = 0.0;
  cl_float sinf = 0.0;
  cl_float structf = 0.0;  
};

struct Palette{
  cl_float3 p1;
  cl_float3 p2;
  cl_float3 p3;
  cl_float3 p4; 
};

struct Object{
  int type;
  cl_float3 position;
  cl_float radius;
  int mat;
  cl_float3 color;
};

struct Scene{
  cl_float3 bg;
  int objects;
  int samples;
  int depth;
};

inline cl_float3 cvert(vec3 v)
{
  cl_float3 r;
  r.x = v.x();
  r.y = v.y();
  r.z = v.z();

  return r;
}

inline vec3 vvert(cl_float3 c)
{
  return vec3(c.x,c.y,c.z);
}

void OpenClinit(vector<char*> files);
float* RunKernal(struct Camera c,struct Shader s,struct Palette p,struct Scene scene,struct Object *scened);
void UpdateCamera(struct Camera* c);

#endif