import std.stdio: writeln;
import std.conv: to;
import std.random: uniform;

import raylib;

void main() {
	immutable int WIDTH = 640;
	immutable int HEIGHT = 480;
	immutable int BLOCK_SIZE = 16;

	// init
	InitWindow(WIDTH, HEIGHT, "Dlang Xonix");
	SetTargetFPS(15);

	// create the game board
	int[HEIGHT/BLOCK_SIZE][WIDTH/BLOCK_SIZE] board = 0;
	for(int i = 0; i < board.length; i++) {
		board[i][0] = 1;
		board[i][board[i].length-1] = 1;
	}

	for(int i = 0; i < board[0].length; i++) {
		board[0][i] = 1;
		board[board.length-1][i] = 1;
	}

	// loading a tileset
	Texture2D tblocks = LoadTexture("res/blocks.png");
	// individual textures from a tile set
	Rectangle[2] srect = [ Rectangle(0, 0, BLOCK_SIZE, BLOCK_SIZE), Rectangle(BLOCK_SIZE, 0, BLOCK_SIZE, BLOCK_SIZE) ];

	Vector2 playerPos = Vector2(0, 0);
	Vector2 ballPos = Vector2(10*BLOCK_SIZE, 10*BLOCK_SIZE);

	// ball movement speed
	int balldx = uniform(-20, 20);
	int balldy = uniform(-20, 20);

	// directions
	bool isUp = false;
	bool isDown = false;
	bool isLeft = false;
	bool isRight = false;

	Rectangle rmuteScreen = Rectangle(0, 0, WIDTH, HEIGHT);
	bool gameOver = false;
	while(!WindowShouldClose()) {
		if(!gameOver) {
			// player coordinates converted to indexes: board[px][py]
			int px = to!int(playerPos.x/BLOCK_SIZE);
			int py = to!int(playerPos.y/BLOCK_SIZE);

			// process events
			if(IsKeyDown(KeyboardKey.KEY_DOWN) || IsKeyDown(KeyboardKey.KEY_S)) {
				isDown = true;
				isUp = false;
				isLeft = false;
				isRight = false;
			} else if(IsKeyDown(KeyboardKey.KEY_UP) || IsKeyDown(KeyboardKey.KEY_W)) {
				isUp = true;
				isDown = false;
				isLeft = false;
				isRight = false;
			} else if(IsKeyDown(KeyboardKey.KEY_RIGHT) || IsKeyDown(KeyboardKey.KEY_D)) {
				isRight = true;
				isDown = false;
				isUp = false;
				isLeft = false;
			} else if(IsKeyDown(KeyboardKey.KEY_LEFT) || IsKeyDown(KeyboardKey.KEY_A)) {
				isLeft = true;
				isDown = false;
				isUp = false;
				isRight = false;
			}

			// moving the player
			if(isUp) {
				py--;
			} else if(isDown) {
				py++;
			} else if(isLeft) {
				px--;
			} else if(isRight) {
				px++;
			}

			// update
			if(py < 0) {
				py = 0;
			} else if(py > board[0].length-1) {
				py = board[0].length-1;
			}

			if(px < 0) {
				px = 0;
			} else if(px > board.length-1) {
				px = board.length-1;
			}

			if(board[px][py] == 2) {
				gameOver = true;
			} else if(board[px][py] != 1) {
				board[px][py] = 2;
			}

			//moving the ball
			ballPos.x += balldx;
			ballPos.y += balldy;

			// ball coordinates converted to indexes: board[bx][by]
			int bx = to!int(ballPos.x/BLOCK_SIZE);
			int by = to!int(ballPos.y/BLOCK_SIZE);

			// ball collision
			if(by < 1) {
				by = 1;
				balldy = -balldy;
			} else if(by > board[0].length-2) {
				by = board[0].length-2;
				balldy = -balldy;
			}

			if(bx < 1) {
				bx = 1;
				balldx = -balldx;
			} else if(bx > board.length-2) {
				bx = board.length-2;
				balldx = -balldx;
			}

			if(board[bx][by] == 1) {
				balldx = -balldx;
				balldy = -balldy;

				ballPos.x += balldx;
				ballPos.y += balldy;

				bx = to!int(ballPos.x/BLOCK_SIZE);
				by = to!int(ballPos.y/BLOCK_SIZE);
			} else if(board[bx][by] == 2) {
				gameOver = true;
			}

			if(board[px][py] == 1) {
				isUp = false;
				isDown = false;
				isLeft = false;
				isRight = false;

				boundaryFill(board, bx, by);

				for(int i = 0; i < board.length; i++) {
					for(int j = 0; j < board[i].length; j++) {
						if(board[i][j] == 3) {
							board[i][j] = 0;
						} else {
							board[i][j] = 1;
						}
					}
				}
			}

			playerPos = Vector2(px*BLOCK_SIZE, py*BLOCK_SIZE);
		}

		// draw
		BeginDrawing();
		ClearBackground(Color(0, 130, 130, 255));

		for(int i = 0; i < board.length; i++) {
			for(int j = 0; j < board[i].length; j++) {
				if(board[i][j] == 1) {
					DrawTextureRec(tblocks, srect[0], Vector2(i*BLOCK_SIZE, j*BLOCK_SIZE), WHITE);
				} else if(board[i][j] == 2) {
					DrawTextureRec(tblocks, srect[1], Vector2(i*BLOCK_SIZE, j*BLOCK_SIZE), WHITE);
				}
			}
		}

		DrawCircleV(ballPos, BLOCK_SIZE/2, WHITE);
		DrawTextureRec(tblocks, srect[1], playerPos, WHITE);

		if(gameOver) {
			DrawRectangle(rmuteScreen.x.to!int, rmuteScreen.y.to!int, rmuteScreen.width.to!int, rmuteScreen.height.to!int, Color(0, 0, 0, 180));
			DrawText("Game Over!", to!int(WIDTH/4.5), HEIGHT/3, 64, WHITE);
		}

		EndDrawing();
	}

	UnloadTexture(tblocks);
	CloseWindow();
}

// boundary fill algorithm
void boundaryFill(ref int[30][40] array, int x, int y) {
	if(array[x][y] == 0) {
		array[x][y] = 3;

		boundaryFill(array, x+1, y);
		boundaryFill(array, x, y+1);
		boundaryFill(array, x-1, y);
		boundaryFill(array, x, y-1);
	}
}









