// Abstraction libary to setup and use OpenCl

#include <Renderer.h>

Platform pform;
vector<Platform> pforms; // list of all platforms available 
Device device;
vector<Device> devices; // list of all device on chosen platform
Context context; // OpenCl context
CommandQueue queue; // Command Queue
const char* kernel_s; // will contain our kernal source code
Program program;
Kernel kernel;

// get user choice
int GetChoice()
{
  int choice;

  int c;
  while ((c = getchar()) != '\n' && c != EOF) { }

  fprintf(stdout,"Select : ");

  if (scanf("%d", &choice) != 1) {
    fprintf(stderr, "Invalid input\n");
    return -1;
  }

  return choice;
}

// git device from user
Device GetDevice(vector<Device> devices)
{
  int choice;

  if (devices.size() == 0) return devices[0];
  else{

    // User input checking
    while (choice <= 0 || choice > devices.size()){
      choice = GetChoice();
      if (choice <= 0 || choice > devices.size()) fprintf(stdout,"Not a Valid Number\n");
    }

    return devices[choice-1];
  }
}

// return platform from user input
Platform GetPlatform(vector<Platform> pforms)
{
  int choice;

  if (pforms.size() == 0) return pforms[0];
  else{

    // User input checking
    while (choice <= 0 || choice > pforms.size()){
      choice = GetChoice();
      if (choice <= 0 || choice > pforms.size()) fprintf(stdout,"Not a Valid Device Number\n");
    }

    return pforms[choice-1];
  }
}

// display devices on platform
void DisplayDevices(vector<Device> devices)
{
  int i;

  fprintf(stdout,"Devices On This Platform\n");

  for (i = 0;i<devices.size();i++){
    fprintf(stdout,"Device %d: %s\n",i+1,devices[i].getInfo<CL_DEVICE_NAME>().c_str());
  }
}

// Display Platforms to users
void DisplayPlatforms(vector<Platform> pforms)
{
  int i;  
  printf("OpenCL Devices\n"); 

  for (i = 0;i<pforms.size();i++){
    fprintf(stdout,"Platform %d: %s\n",i+1,pforms[i].getInfo<CL_PLATFORM_NAME>().c_str());
    fprintf(stdout,"Press Enter to continue\n");
  }
}

// Extracts and links all kernal source code files
const char* DownloadKernalCode(vector<char*> files)
{
  string source;
   // kernal.cl contains kernal code to run on GPU
  const char* kernel_s;
  int i;
  
  for (i = 0;i<files.size();i++){
    ifstream file(files[i]);
    if (!file){
      fprintf(stderr,"Cant Find %s\n", files[i]);
	  exit(1);
    }
    while (!file.eof()){
	  char line[256];
	  file.getline(line, 255);
	  source += line;
    }
  }

  kernel_s = source.c_str();

  return kernel_s;
}

void printErrorLog(const Program& program, const Device& device){

	// Get the error log and print to console
	string buildlog = program.getBuildInfo<CL_PROGRAM_BUILD_LOG>(device);

	// Print the error log to a file
	FILE *log = fopen("errorlog.txt", "w");
	fprintf(log, "%s\n", buildlog);
	exit(1);
}

void OpenClinit(vector<char*> files)
{
  
  Platform::get(&pforms); // get all platforms
  DisplayPlatforms(pforms); // Display platforms to user  

  pform = GetPlatform(pforms); // choosing our platform
  fprintf(stdout,"Using Platform: %s\n",pform.getInfo<CL_PLATFORM_NAME>().c_str()); // Displaying picked platform

  pform.getDevices(CL_DEVICE_TYPE_ALL, &devices); // get devices on platfrom
  DisplayDevices(devices); // display devices
  device = GetDevice(devices); // choosing our device
  fprintf(stdout,"Using Device: %s\n",device.getInfo<CL_DEVICE_NAME>().c_str()); // Displaying picked Device

  context = Context(device);
  queue = CommandQueue(context, device);

  kernel_s = DownloadKernalCode(files); // link kernal source files and store them

  fprintf(stdout,"Kernal Source Code Downloaded\n");

  // compiling kernal code
  program = Program(context, kernel_s);
  if ( program.build({ device }) ) {
    fprintf(stderr,"Error durring Compilation of kernal code");
    printErrorLog(program, device);
    }

  kernel = Kernel(program, "kernel_main"); // kernal entry point

  fprintf(stdout,"Kernal compiled\n");

}


cl_float* RunKernal(struct Camera c)
{

  cl_float* output = new float[c.width*c.height*3]; // gpu output
  float input[3] = { 3.0 , 7.0, 23.0}; // gpu input
  float factor = 9.0;

  Buffer gpu_output = Buffer(context, CL_MEM_WRITE_ONLY,c.width*c.height*3*sizeof(cl_float)); //output buffer
  Buffer gpu_input = Buffer(context,CL_MEM_READ_ONLY,3*sizeof(float)); // input buffer
  queue.enqueueWriteBuffer(gpu_input, CL_TRUE, 0, 3*sizeof(float), input); // write to the input buffer


  // setting kernal args
  kernel.setArg(0, gpu_input);
  kernel.setArg(1, c);
  kernel.setArg(2, gpu_output);

  // each index of output will be computed at same time
  std::size_t global_work_size = c.width * c.height;
	std::size_t local_work_size = kernel.getWorkGroupInfo<CL_KERNEL_WORK_GROUP_SIZE>(device);

	if (global_work_size % local_work_size != 0) global_work_size = (global_work_size / local_work_size + 1) * local_work_size;

  // run kernel code
	queue.enqueueNDRangeKernel(kernel, NULL, global_work_size, local_work_size);
	queue.finish();

  // read from the output buffer
  queue.enqueueReadBuffer(gpu_output, CL_TRUE, 0, c.width*c.height*3*sizeof(cl_float), output);

  // display output
  
  /*
  for (int i = 0; i< c.width*c.height;i++){
      printf("(%d) = {%2f,%2f,%2f} ",i,output[i].s[0],output[i].s[1],output[i].s[2]);
    
    printf("\n");
  }
  */
  

  return output;
}

void UpdateCamera(struct Camera *c)
{
  c->height = int(c->width/c->aspect_ratio);

  c->focal_length = subtractVectors(vvert(c->position),vvert(c->look)).length();

  float h = std::tan(degrees_to_radians(c->fov)/2);

  c->viewport_h = 2*h*c->focal_length;
  c->viewport_w = c->viewport_h*(double(c->width)/double(c->height));

  c->dw = cvert(unitVector(subtractVectors(vvert(c->position),vvert(c->look))));
  c->du = cvert(unitVector(crossproduct(vvert(c->vup),vvert(c->dw))));
  c->dv = cvert(crossproduct(vvert(c->dw),vvert(c->du)));

  c->viewport_u = cvert(SmultiVector(c->viewport_w,vvert(c->du)));
  c->viewport_v = cvert(SmultiVector(c->viewport_h,SmultiVector(-1,vvert(c->dv)))); 

  c->delta_u = cvert(SdivideVector(c->width,vvert(c->viewport_u))); // change between pixels horizotanlly
  c->delta_v = cvert(SdivideVector(c->height,vvert(c->viewport_v)));// change between pixels vertically

  c->vp_upperleft = cvert(subtractVectors(subtractVectors(subtractVectors(vvert(c->position),SmultiVector(c->focal_length,vvert(c->dw))),SdivideVector(2,vvert(c->viewport_u))),SdivideVector(2,vvert(c->viewport_v))));

  c->pixel_location = cvert(addVectors(vvert(c->vp_upperleft),SmultiVector(0.5,addVectors(vvert(c->delta_u),vvert(c->delta_v)))));

  printf("%f, %f, %f\n",c->pixel_location.x,c->pixel_location.y,c->pixel_location.z);

}

