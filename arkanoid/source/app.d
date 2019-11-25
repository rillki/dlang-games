import std.stdio;
import std.conv;

import raylib;

void main() {
	immutable short WIDTH = 640;
	immutable short HEIGHT = 580;

	int dx = 7, dy = 4, da = 0;
	int intersections = 0;
	bool change_dx = false, change_dy = false;

	//	init
	InitWindow(WIDTH, HEIGHT, "Dlang Arkanoid");
	SetTargetFPS(60);
	SetMouseScale(1.0, 1.0);

	Texture2D tbackground = LoadTexture("res/background.png");
	tbackground.width = WIDTH;
	tbackground.height = HEIGHT;

	Rectangle playerPaddle = Rectangle(WIDTH/2-100, HEIGHT-40, 200, 20);

	int ballRadius = 16;
	Vector2 ball = Vector2(WIDTH/2-ballRadius/2, HEIGHT*4/6);

	bool[12][14] boolArks = true;
	Rectangle[12][14] arks = Rectangle(0, 0, 48, 16);
	for(int i = 0; i < arks.length; i++) {
		for(int j = 0; j < arks[i].length; j++) {
			arks[i][j].x = arks[i][j].width*j+j*6;
			arks[i][j].y = arks[i][j].height*i+i*3;
		}
	}

	Rectangle rmuteScreen = Rectangle(0, 0, WIDTH, HEIGHT);

	bool muteScreen = true;
	bool gameWon = false;
	while (!WindowShouldClose()) {
		//	game logic
		if(!muteScreen && !gameWon) {
			int mousePos = GetMousePosition().x.to!int;
			playerPaddle.x = mousePos - playerPaddle.width/2;

			if(change_dx) {
				ball.x += dx+da;
			} else {
				ball.x -= dx+da;
			}

			if(change_dy) {
				ball.y += dy+da;
			} else {
				ball.y -= dy+da;
			}

			if(ball.x > WIDTH || ball.x < 0) {
				change_dx = !change_dx;
			} else if(ball.y < 0) {
				change_dy = !change_dy;
			} else if(ball.y > HEIGHT) {
				ball = Vector2(WIDTH/2-ballRadius/2, HEIGHT*4/6);

				muteScreen = !muteScreen;
				da = 0;
			}

			if(CheckCollisionCircleRec(ball, ballRadius, playerPaddle)) {
				change_dy = !change_dy;
				
				if(--da < 0) {
					da = 0;
				}

				float temp = ball.y - playerPaddle.y;
				ball.y += temp;
			}

			for(int i = 0; i < arks.length; i++) {
				for(int j = 0; j < arks[i].length; j++) {
					if(boolArks[i][j]) {
						if(CheckCollisionCircleRec(ball, ballRadius, arks[i][j])) {
							change_dx = !change_dx;
							change_dy = !change_dy;

							boolArks[i][j] = false;
							intersections++;
							da++;
						}
					}
				}
			}

			if(intersections >= 12*14) {
				gameWon = true;
			}



			//	end logic
		}

		//	processing events
		if(IsKeyPressed(KeyboardKey.KEY_SPACE)) {
			muteScreen = !muteScreen;
		}

		if(IsKeyPressed(KeyboardKey.KEY_P)) {
			gameWon = true;
		}

		//	drawing to screen
		BeginDrawing();
		ClearBackground(BLACK);

		DrawTexture(tbackground, 0, 0, WHITE);
		DrawRectangleRec(playerPaddle, WHITE);

		for(int i = 0; i < arks.length; i++) {
			for(int j = 0; j < arks[i].length; j++) {
				if(boolArks[i][j]) {
					DrawRectangleRec(arks[i][j], WHITE);
				}
			}
		}

		DrawCircleV(ball, ballRadius, WHITE);

		if(muteScreen && !gameWon) {
			DrawRectangleRec(rmuteScreen, Color(0, 0, 0, 210));
			DrawText("Press SPACE to play", WIDTH/10, HEIGHT/3, 48, WHITE);
		}

		if(gameWon) {
			DrawRectangleRec(rmuteScreen, Color(0, 0, 0, 210));
			DrawText("You Won!", WIDTH/3, HEIGHT/3, 48, WHITE);
		}

		EndDrawing();
	}

	UnloadTexture(tbackground);
	CloseWindow();
}
