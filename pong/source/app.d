import std.stdio;
import std.conv;
import std.string: toStringz;

import raylib;

void main() {
	immutable short WIDTH = 640;
	immutable short HEIGHT = 480;

	int playerScore = 0, opponentScore = 0;

	int dx = 6, dy = 5;
	float da = 0;
	bool change_dx = true, change_dy = false;

	//	init
	InitWindow(WIDTH, HEIGHT, "Dlang Pong");
	SetTargetFPS(60);
	SetMouseScale(1.0, 1.0);

	Rectangle playerPaddle = Rectangle(WIDTH-50, HEIGHT/2-100, 25, 200);
	Rectangle opponentPaddle = Rectangle(25, HEIGHT/2-100, 25, 200);

	int ballRadius = 16;
	Vector2 ball = Vector2(WIDTH/2-ballRadius/2, HEIGHT/2-ballRadius/2);

	float playerPaddle_dy = 0;
	while (!WindowShouldClose()) {
		//	game logic
		float testVar = playerPaddle.y+playerPaddle.height/2;

		int mousePos = GetMousePosition().y.to!int;
		playerPaddle.y = mousePos - playerPaddle.height/2;

		if(change_dx) {		// change direction
			ball.x += dx+da;
		} else {
			ball.x -= dx+da;
		}

		if(change_dy) {		// change direction
			ball.y += dy+da;
		} else {
			ball.y -= dy+da;
		}

		if(ball.x > WIDTH || ball.x < 0) {		//	check if we/our opponent scored a point
			if(ball.x > WIDTH) {
				opponentScore++;
			} else if(ball.x < 0) {
				playerScore++;
			}

			ball = Vector2(WIDTH/2-ballRadius/2, HEIGHT/2-ballRadius/2); //	if true reset the game

			da = 0;
		} else if(ball.y < 0 || ball.y > HEIGHT) {	//	checking whether the ball should bounce in the opposite direction
			change_dy = !change_dy;

			if(ball.y < 0) {
				ball.y = 0;
			} else if (ball.y > HEIGHT) {
				ball.y = HEIGHT - ballRadius;
			}
		}

		if(CheckCollisionCircleRec(ball, ballRadius, playerPaddle)) {	// does ball collide with playerPaddle?
			change_dx = !change_dx;

			if(ball.x < HEIGHT/2) {
				change_dy = !change_dy;
			}

			float temp = ball.x+ballRadius - playerPaddle.x;
			ball.x -= temp;

			da++;

			testVar = playerPaddle.y+playerPaddle.height/2 - testVar;
	    	if(testVar < 0) {
	    		change_dy = false;
	    	} else if(testVar > 0) {
	    		change_dy = true;
	    	}
		}

		if(CheckCollisionCircleRec(ball, ballRadius, opponentPaddle)) {	// does ball collide with opponentPaddle?
			change_dx = !change_dx;

			if(ball.x < HEIGHT/2) {
				change_dy = !change_dy;
			}

			float temp = opponentPaddle.x+opponentPaddle.width - ball.x + ballRadius;
			ball.x += temp;
		}

		if (opponentPaddle.y+opponentPaddle.height/2 > ball.y) {
    		opponentPaddle.y -= dy;
    	} else {
    		opponentPaddle.y += dy;
    	}

		//	process events


		//	draw to screen
		BeginDrawing();
		ClearBackground(Color( 100, 228, 48, 255 ));

		DrawRectangleRec(playerPaddle, WHITE);
		DrawRectangleRec(opponentPaddle, WHITE);
		DrawCircleV(ball, ballRadius, WHITE);

		DrawText(toStringz(opponentScore.to!string), WIDTH/3, 10, 30, WHITE);
		DrawText(toStringz(playerScore.to!string), WIDTH*2/3, 10, 30, WHITE);

		EndDrawing();
	}

	CloseWindow();
}
