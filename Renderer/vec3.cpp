#include "vec3.h"

// Prints out vector [x,y,z]
void printVector(FILE *stream,vec3 v)
{
  fprintf(stream,"%lf %lf %lf\n",v.x(),v.y(),v.z());
}

// adds 2 vectors and returns a new one
vec3 addVectors(vec3 v1,vec3 v2)
{
  return vec3(v1.x() + v2.x(),v1.y() + v2.y(),v1.z() + v2.z());
}

// subtracts 2 vectors and returns a new one
vec3 subtractVectors(vec3 v1,vec3 v2)
{
  return vec3(v1.x() - v2.x(),v1.y() - v2.y(),v1.z() - v2.z());
}

// multiplys 2 vectors and returns a new one
vec3 multiVectors(vec3 v1,vec3 v2)
{
  return vec3(v1.x() * v2.x(),v1.y() * v2.y(),v1.z() * v2.z());
}

// scalar multiplys a vector and returns a new one
vec3 SmultiVector(float s,vec3 v)
{
  return vec3(s*v.x(),s*v.y(),s*v.z());
}

// scalar divides a vector and returns a new one
vec3 SdivideVector(float s,vec3 v)
{
  return vec3(v.x()/s,v.y()/s,v.z()/s);
}

// returns the dot product of 2 vectors
float dot(vec3 v1,vec3 v2) {
    return v1.x() * v2.x()
         + v1.y() * v2.y()
         + v1.z() * v2.z();
}

// returns crossproduct of 2 vectors
vec3 crossproduct(vec3 v1, vec3 v2) {
    return vec3(v1.y() * v2.z() - v1.z() * v2.y(),
                v1.z() * v2.x() - v1.x() * v2.z(),
                v1.x() * v2.y() - v1.y() * v2.x());
}

// returns unit vector of a vector
vec3 unitVector(vec3 v)
{
  return SdivideVector(v.length(),v);
}

vec3 reflect(vec3 v,vec3 u)
{
  return subtractVectors(v,SmultiVector(2*dot(v,u),u));
}

vec3 refract(vec3 uv,vec3 n,float et)
{
  float ct = std::fmin(dot(SmultiVector(-1,uv),n),1.0);
  vec3 r_outpd = SmultiVector(et,addVectors(uv,SmultiVector(ct,n)));
  vec3 r_outpll = SmultiVector(-std::sqrt(std::fabs(1.0 - r_outpd.length()*r_outpd.length())),n);

  return addVectors(r_outpd,r_outpll);
}