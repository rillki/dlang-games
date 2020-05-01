module app;

import data;

void main() {
    InitWindow(screenWidth, screenHeight, "Dlang Pseudo 3D Outurn");
    scope(exit) CloseWindow();

    SetTargetFPS(60);

    Vector3 camera = Vector3(1, 1, 1);
    Vector3 world = Vector3(20, 100, 34.64);
    Vector2 screen = Vector2(1, 1);
    
    Rectangle rcar = Rectangle(screenWidth/2-50, screenHeight*2/3, 100, 50);

    while(!WindowShouldClose()) {
	// process events
	if(IsKeyDown(KeyboardKey.KEY_RIGHT)) fcar_dist += 2.0f;
        if(IsKeyDown(KeyboardKey.KEY_LEFT)) fcar_dist -= 2.0f;
        if(IsKeyDown(KeyboardKey.KEY_UP)) fcar_dist += 10.0f;
        if(IsKeyDown(KeyboardKey.KEY_DOWN)) fcar_dist -= 10.0f;
	// update
	
	// render
    	BeginDrawing();
        ClearBackground(WHITE);

	drawRoad();
	DrawRectangleRec(rcar, BLACK);

        EndDrawing();
    }
}
