#ifndef OPENCLABSTRACTIONS_H
#define OPENCLABSTRACTIONS_H

#include <cl.hpp>
#include <vector>
#include <stdio.h>
#include <stdlib.h>
#include <fstream>

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

void OpenClinit(vector<char*> files);

cl_float3* RunKernal();

#endif