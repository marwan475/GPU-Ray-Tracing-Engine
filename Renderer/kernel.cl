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

__kernel void kernel_main(__constant float* input,float factor,__global float3* output)
{
  unsigned int work_item_id = get_global_id(0);	/* the unique global id of the work item for current index*/
  int x_index = work_item_id % 10;	
  int y_index = work_item_id / 10;

  float3 i = {input[0]*factor + input[1]*factor + input[2]*factor,random(x_index,y_index),x_index + y_index};

  output[work_item_id] = i;		
}