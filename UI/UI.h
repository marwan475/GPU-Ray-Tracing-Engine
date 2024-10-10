#ifndef UI_H
#define UI_H

#include <GL/GL.h>

struct Camera;

void UI(GLuint texture,struct Camera* c,struct Shader *s,struct Palette *p,struct Scene *scene,struct Object* scened); 

#endif