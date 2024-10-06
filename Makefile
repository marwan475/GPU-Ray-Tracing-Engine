CXX = g++
CXXFLAGS = -I./imgui -I./UI -I./Renderer 
LDFLAGS = -lopengl32 -lgdi32 -ldwmapi C:\\WINDOWS\system32\OpenCL.dll

SOURCES = Engine.cpp UI/UI.cpp Renderer/vec3.cpp imgui/imgui.cpp imgui/imgui_draw.cpp imgui/imgui_widgets.cpp imgui/imgui_tables.cpp imgui/imgui_demo.cpp imgui/imgui_impl_win32.cpp imgui/imgui_impl_opengl3.cpp

OBJECTS = $(SOURCES:.cpp=.o)

all: Engine.exe

Engine.exe: $(OBJECTS) Renderer.o
	$(CXX) -o $@ $^ $(LDFLAGS)

Renderer.o: Renderer/Renderer.cpp
	g++ -w Renderer/Renderer.cpp -c -I./Renderer -o Renderer.o

clean:
	rm -f imgui/*.o Engine.exe *.o UI/*.o Renderer/*.o

