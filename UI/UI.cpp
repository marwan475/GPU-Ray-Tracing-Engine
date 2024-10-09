#include <UI.h>
#include "imgui.h"
#include <stdio.h>
#include <Renderer.h>

void UI(GLuint texture,struct Camera *c,struct Shader *shader,struct Palette* p,struct Scene *scene) 
{
    static bool opt_fullscreen = true;
    static bool opt_padding = false;
    static ImGuiDockNodeFlags dockspace_flags = ImGuiDockNodeFlags_None;

    ImGuiWindowFlags window_flags = ImGuiWindowFlags_MenuBar | ImGuiWindowFlags_NoDocking;
    if (opt_fullscreen)
    {
        const ImGuiViewport* viewport = ImGui::GetMainViewport();
        ImGui::SetNextWindowPos(viewport->WorkPos);
        ImGui::SetNextWindowSize(viewport->WorkSize);
        ImGui::SetNextWindowViewport(viewport->ID);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0.0f);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0.0f);
        window_flags |= ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove;
        window_flags |= ImGuiWindowFlags_NoBringToFrontOnFocus | ImGuiWindowFlags_NoNavFocus;
    }
    else
    {
        dockspace_flags &= ~ImGuiDockNodeFlags_PassthruCentralNode;
    }

    if (dockspace_flags & ImGuiDockNodeFlags_PassthruCentralNode)
        window_flags |= ImGuiWindowFlags_NoBackground;


    if (!opt_padding)
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0.0f, 0.0f));
    ImGui::Begin("DockSpace Demo", nullptr, window_flags);
    if (!opt_padding)
        ImGui::PopStyleVar();

    if (opt_fullscreen)
        ImGui::PopStyleVar(2);

    // Submit the DockSpace
    ImGuiIO& io = ImGui::GetIO();
    if (io.ConfigFlags & ImGuiConfigFlags_DockingEnable)
    {
        ImGuiID dockspace_id = ImGui::GetID("MyDockSpace");
        ImGui::DockSpace(dockspace_id, ImVec2(0.0f, 0.0f), dockspace_flags);
    }

    if (ImGui::BeginMenuBar())
    {
        if (ImGui::BeginMenu("Options"))
        {
            ImGui::MenuItem("Fullscreen", NULL, &opt_fullscreen);
            ImGui::MenuItem("Padding", NULL, &opt_padding);
            ImGui::Separator();

            if (ImGui::MenuItem("Flag: NoDockingOverCentralNode", "", (dockspace_flags & ImGuiDockNodeFlags_NoDockingOverCentralNode) != 0)) { dockspace_flags ^= ImGuiDockNodeFlags_NoDockingOverCentralNode; }
            if (ImGui::MenuItem("Flag: NoDockingSplit",         "", (dockspace_flags & ImGuiDockNodeFlags_NoDockingSplit) != 0))             { dockspace_flags ^= ImGuiDockNodeFlags_NoDockingSplit; }
            if (ImGui::MenuItem("Flag: NoUndocking",            "", (dockspace_flags & ImGuiDockNodeFlags_NoUndocking) != 0))                { dockspace_flags ^= ImGuiDockNodeFlags_NoUndocking; }
            if (ImGui::MenuItem("Flag: NoResize",               "", (dockspace_flags & ImGuiDockNodeFlags_NoResize) != 0))                   { dockspace_flags ^= ImGuiDockNodeFlags_NoResize; }
            if (ImGui::MenuItem("Flag: AutoHideTabBar",         "", (dockspace_flags & ImGuiDockNodeFlags_AutoHideTabBar) != 0))             { dockspace_flags ^= ImGuiDockNodeFlags_AutoHideTabBar; }
            if (ImGui::MenuItem("Flag: PassthruCentralNode",    "", (dockspace_flags & ImGuiDockNodeFlags_PassthruCentralNode) != 0, opt_fullscreen)) { dockspace_flags ^= ImGuiDockNodeFlags_PassthruCentralNode; }
            ImGui::Separator();

            ImGui::EndMenu();
        }
 

        ImGui::EndMenuBar();
    }

    // FLAGS

    static ImGuiWindowFlags flags = !ImGuiWindowFlags_NoMove | !ImGuiWindowFlags_NoResize;

    // SCENE

    ImGui::Begin("Scene",nullptr,flags);


    if (ImGui::TreeNode("Item Tree"))
        {
            for (int i = 0; i < 10; i++)
            {
                if (i == 0)
                    ImGui::SetNextItemOpen(true, ImGuiCond_Once);

                ImGui::PushID(i);
                if (ImGui::TreeNode("", "item %d", i))
                {
                    ImGui::Text("sub item");
                    if (ImGui::SmallButton("sub item button")) {
                        printf("Sub item button pressed");
                    }
                    ImGui::TreePop();
                }
                ImGui::PopID();
            }
            ImGui::TreePop();
        }

    static ImVec4 color = ImVec4(114.0f / 255.0f, 144.0f / 255.0f, 154.0f / 255.0f, 200.0f / 255.0f);
    ImGui::SeparatorText("Background Color");

    ImGui::ColorPicker3("##MyColor##5", (float*)&color, ImGuiColorEditFlags_PickerHueBar | ImGuiColorEditFlags_NoSidePreview | ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_NoAlpha);

    scene->bg.x = color.x;
    scene->bg.y = color.y;
    scene->bg.z = color.z;


    if (0){
        printf("%2f %2f %2f\n",color.x,color.y,color.z);
    }

    ImGui::End();

    // VIEW PORT

    ImGui::Begin("ViewPort",nullptr,flags);
    if (texture) {
        
        ImGui::Text("Framerate: %f fps",ImGui::GetIO().Framerate);
        ImGui::Image((void*)(intptr_t)texture, ImVec2(c->width, c->height)); // Use actual dimensions
    } else {
        ImGui::Text("Failed to create texture.");
    }
    ImGui::End();

    ImGui::Begin("test2",nullptr,flags);
    ImGui::End();

    // SHADERS

    ImGui::Begin("Shaders",nullptr,flags);

    if (ImGui::Button("Toggle Shader view")) {
        if (c->mode == 0) {
            c->mode = 1;
        }
        else c->mode = 0;
    }

    if (c->mode >= 1) {
            if(ImGui::Button("Switch Shader")){
              if (c->mode == 2) c->mode = 1;
              else c->mode++; 
            }
        }

    if (c->mode == 2){
      ImGui::Text("Shader Editor");

      ImGui::SliderFloat("Glow", &(shader->glowfactor), 0.01f, 1.0f);
      ImGui::SliderFloat("Pulse", &(shader->pulsefactor), 1.0f, 100.0f);
      ImGui::SliderFloat("Fractal", &(shader->fractalfactor), 1.0f, 10.0f);
      ImGui::SliderFloat("Color rate", &(shader->colorfactor), 0.0f, 5.0f);
      ImGui::SliderFloat("Frequency Factor", &(shader->freqfactor), -10.0f, 10.0f);
      ImGui::SliderFloat("Fractal Variance", &(shader->fractalvariance), 0.0f, 10.0f);
      ImGui::InputInt("Iterations", &(shader->iterations));
    
      ImGui::InputInt("Palette ON", &(shader->pal));
      ImGui::SliderFloat("Color Fractal", &(shader->cfractalfactor), 1.0f, 10.0f);
      ImGui::InputInt("S Fractal ON", &(shader->sfractal));
      ImGui::InputInt("C Fractal ON", &(shader->cfractal));
      ImGui::SliderFloat("Time Rate", &(shader->t), 0.0f, 10.0f);
      ImGui::SliderFloat("Sine Factor", &(shader->sinf), 0.0f, 1.0f);
      ImGui::SliderFloat("Structural Factor", &(shader->structf), 0.0f, 1.0f);

      static ImVec4 color1 = ImVec4(114.0f / 255.0f, 144.0f / 255.0f, 154.0f / 255.0f, 200.0f / 255.0f);
      ImGui::SeparatorText("Palette");

      ImGui::ColorPicker3("##MyColor##1", (float*)&color1, ImGuiColorEditFlags_PickerHueBar | ImGuiColorEditFlags_NoSidePreview | ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_NoAlpha);

      static ImVec4 color2 = ImVec4(114.0f / 255.0f, 144.0f / 255.0f, 154.0f / 255.0f, 200.0f / 255.0f);

      ImGui::ColorPicker3("##MyColor##2", (float*)&color2, ImGuiColorEditFlags_PickerHueBar | ImGuiColorEditFlags_NoSidePreview | ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_NoAlpha);

      static ImVec4 color3 = ImVec4(114.0f / 255.0f, 144.0f / 255.0f, 154.0f / 255.0f, 200.0f / 255.0f);

      ImGui::ColorPicker3("##MyColor##3", (float*)&color3, ImGuiColorEditFlags_PickerHueBar | ImGuiColorEditFlags_NoSidePreview | ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_NoAlpha);

      static ImVec4 color4 = ImVec4(114.0f / 255.0f, 144.0f / 255.0f, 154.0f / 255.0f, 200.0f / 255.0f);

      ImGui::ColorPicker3("##MyColor##4", (float*)&color4, ImGuiColorEditFlags_PickerHueBar | ImGuiColorEditFlags_NoSidePreview | ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_NoAlpha);

      p->p1.x = color1.x;
      p->p1.y = color1.y;
      p->p1.z = color1.z;

      p->p2.x = color2.x;
      p->p2.y = color2.y;
      p->p2.z = color2.z;

      p->p3.x = color3.x;
      p->p3.y = color3.y;
      p->p3.z = color3.z;

      p->p4.x = color4.x;
      p->p4.y = color4.y;
      p->p4.z = color4.z;
    }

    ImGui::End();


    ImGui::End();


  

  //ImGui::ShowDemoWindow();
}