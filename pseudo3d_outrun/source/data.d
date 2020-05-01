module data;

public import raylib;

public import std.stdio: warn = writeln;
public import std.conv: to;

import std.math: tan, sin, pow;

immutable screenWidth = 800;
immutable screenHeight = 450;
immutable screenDepth = (screenWidth/2)/tan(30f);

float fcar_dist = 0f;

struct Trapezoid {
    Vector2 p1 = Vector2(0, 0);
    Vector2 p2 = Vector2(0, 0);
    Vector2 p3 = Vector2(0, 0);
    Vector2 p4 = Vector2(0, 0);

    this(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4) {
	this.p1 = p1;
	this.p2 = p2;
	this.p3 = p3;
	this.p4 = p4;
    }

    // draw a trapezoid in clock-wise order!!!
    void draw(Color c) {
	DrawTriangle(p1, p4, p3, c);
	DrawTriangle(p3, p2, p1, c);
    }
}

void drawRoad() {
    for(int i = 0; i < screenHeight/2; i++) {
	for(int j = 0; j < screenWidth; j++) {
	    float fperspective = (i.to!float)/(screenHeight/2f);
	    float fmiddlePoint = 0.5f;
	    float froadWidth = 0.1f + fperspective*0.8;
	    float fclipRoadWidth = froadWidth*0.15f;
	    
	    froadWidth *= 0.5;

	    float fleftGrass = screenWidth*(fmiddlePoint-froadWidth-fclipRoadWidth);
	    float fleftClip = screenWidth*(fmiddlePoint-froadWidth);
	    float frightGrass = screenWidth*(fmiddlePoint+froadWidth+fclipRoadWidth);
	    float frightClip = screenWidth*(fmiddlePoint+froadWidth);
	    
	    int nRow = i + screenHeight/2;
	    Color grassColor = sin(20f*pow(1-fperspective, 3)+fcar_dist*0.1f) > 0 ? GREEN : DARKGREEN;
	    Color clipColor = sin(80f*pow(1-fperspective, 3)+fcar_dist*0.1f) > 0 ? RED : WHITE;
	    
	    if(j >= 0 && j < fleftGrass) {
		DrawPixel(j, nRow, grassColor);
	    }

	    if(j >= fleftGrass && j < fleftClip) {
		DrawPixel(j, nRow, clipColor);
	    }

	    if(j >= fleftClip && j < frightClip) {
		DrawPixel(j, nRow, GRAY);
	    }

	    if(j >= frightClip && j < frightGrass) {
		DrawPixel(j, nRow, clipColor);
	    }

	    if(j >= frightGrass && j < screenWidth) {
		DrawPixel(j, nRow, grassColor);
	    }
	}
    }
}

void convertWorldToScreenCoord(ref Vector2 screen, Vector3 camera, Vector3 world) {
	// translate
	float x = world.x - camera.x;
	float y = world.y - camera.y;
	float z = world.z - camera.z;

	// project
	x *= screenDepth/z;
	y *= screenDepth/z;

	// scale
	screen.x = screenWidth/2 + (screenWidth/2)*x;
	screen.y = screenHeight/2 + (screenHeight/2)*y;
}
