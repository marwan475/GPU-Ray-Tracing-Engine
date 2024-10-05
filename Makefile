CXX = g++
CXXFLAGS = -I./imgui -I./UI
LDFLAGS = -lopengl32 -lgdi32 -ldwmapi

SOURCES = Engine.cpp UI/UI.cpp imgui/imgui.cpp imgui/imgui_draw.cpp imgui/imgui_widgets.cpp imgui/imgui_tables.cpp imgui/imgui_demo.cpp imgui/imgui_impl_win32.cpp imgui/imgui_impl_opengl3.cpp

OBJECTS = $(SOURCES:.cpp=.o)

all: Engine.exe

Engine.exe: $(OBJECTS)
	$(CXX) -o $@ $^ $(LDFLAGS)

clean:
	rm -f imgui/*.o Engine.exe *.o

