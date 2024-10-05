#ifndef UTILITY_H
#define UTILITY_H

#include <cmath>
#include <cstdlib>
#include "vec3.h"

const double pi = 3.1415926535897932385;

inline double degrees_to_radians(double degrees) 
{
    return degrees * pi / 180.0;
}

inline double random_double() 
{
    // Returns a random real in [0,1).
    return std::rand() / (RAND_MAX + 1.0);
}

inline double random_double(double min, double max) 
{
    // Returns a random real in [min,max).
    return min + (max-min)*random_double();
}

inline double clamp(double x,double min,double max)
{
  if (x < min) return min;
  if (x > max) return max;
  return x;
}

inline vec3 sample_square() 
{
  // Returns the vector to a random point in the [-.5,-.5]-[+.5,+.5] unit square.
  return vec3(random_double() - 0.5, random_double() - 0.5, 0);
}

inline vec3 randVec() 
{
  return vec3(random_double(), random_double(), random_double());
}

inline vec3 randVecMM(double min, double max) 
{
  return vec3(random_double(min,max), random_double(min,max), random_double(min,max));
}

inline vec3 randUvec()
{
  while(1){
    vec3 p = randVecMM(-1,1);
    double len = p.length()*p.length();
    if (1e-160 < len && len <= 1) return SdivideVector(sqrt(len),p);
  } 
}

inline vec3 randHem(vec3 norm)
{
  vec3 on = randUvec();

  if (dot(on,norm)> 0.0) return on;
  else return SmultiVector(-1,on);
}

inline double linear_to_gamma(double linear_component)
{
    if (linear_component > 0)
        return std::sqrt(linear_component);

    return 0;
}

inline bool near_zero(vec3 v) 
{
  return (std::fabs(v.x()) < 1e-8) && (std::fabs(v.y()) < 1e-8) && (std::fabs(v.z()) < 1e-8);
}

inline double reflectance(double cos,double rid)
{
  double r0 = (1-rid)/(1+rid);
  r0 *= r0;
  return r0 + (1-r0)*std::pow((1-cos),5);
}


#endif