import std.stdio;

import raylib;

struct Cell {
	Texture2D t;
	Rectangle rect;

	char type = ' ';
	bool marked = false;
}

void main() {
	immutable short WIDTH = 640;
	immutable short HEIGHT = 640;
	immutable short SIZE = 213;

	bool gameOver = false;
	bool draw = false;
	bool playersMove = true;

	//	init
	InitWindow(WIDTH, HEIGHT, "Dlang Tic Tac Toe (Noughts and Crosses)");
	SetTargetFPS(60);
	SetMouseScale(1.0, 1.0);

	// loading textures for 'x' and 'o'
	Texture2D tcrosses = LoadTexture("res/cross.png");
	Texture2D tnoughts = LoadTexture("res/nought.png");

	//	initializing the game board
	int positions = 0;
	Cell[3][3] cells;
	for(int i = 0; i < cells.length; i++) {
		for(int j = 0; j < cells[i].length; j++) {
			cells[i][j].rect.width = cells[i][j].rect.height = SIZE;

			cells[i][j].rect.x = i*SIZE;
			cells[i][j].rect.y = j*SIZE;
		}
	}

	//	drawing a grid on the board
	Vector2[2] startPosV = [ Vector2(WIDTH/3, 0), Vector2(WIDTH*2/3, 0) ];
	Vector2[2] endPosV = [ Vector2(WIDTH/3, HEIGHT), Vector2(WIDTH*2/3, HEIGHT) ];

	Vector2[2] startPosH = [ Vector2(0, HEIGHT/3), Vector2(0, HEIGHT*2/3) ];
	Vector2[2] endPosH = [ Vector2(WIDTH, HEIGHT/3), Vector2(WIDTH, HEIGHT*2/3) ];

	// game over screen
	Rectangle rectMuteScreen;
	rectMuteScreen.x = rectMuteScreen.y = 0;
	rectMuteScreen.width = WIDTH;
	rectMuteScreen.height = HEIGHT;

	bool mouseButtonPressed = false;
	while (!WindowShouldClose()) {
		//	game logic
		if(!gameOver && !draw) {
			Vector2 mousePos = GetMousePosition();

			//	if mouse button is pressed, we check whether an entry is empty or preoccupied by 'x' or 'o'
			//	if it is empty, we mark the entry by our pieces: 'x' or 'o'
			if(mouseButtonPressed) {
				for(int i = 0; i < cells.length; i++) {
					for(int j = 0; j < cells[i].length; j++) {
						if(mousePos.x > cells[i][j].rect.x &&
							mousePos.y > cells[i][j].rect.y &&
							mousePos.x < cells[i][j].rect.x+SIZE &&
							mousePos.y < cells[i][j].rect.y+SIZE && !cells[i][j].marked) {	

							if(playersMove) {
								cells[i][j].t = tcrosses;
								cells[i][j].type = 'x';
							} else {
								cells[i][j].t = tnoughts;
								cells[i][j].type = 'o';
							}

							cells[i][j].marked = true;
							playersMove = !playersMove;
							positions++;
							break;
						}
					}
				}

				mouseButtonPressed = false;
			}

			//	checking if game is over
			if(cells[0][0].marked && cells[0][1].marked && cells[0][2].marked) {
				if(cells[0][0].type == cells[0][1].type && cells[0][1].type == cells[0][2].type) {
					gameOver = true;
				}
			}

			if(cells[1][0].marked && cells[1][1].marked && cells[1][2].marked) {
				if(cells[1][0].type == cells[1][1].type && cells[1][1].type == cells[1][2].type) {
					gameOver = true;
				}
			}

			if(cells[2][0].marked && cells[2][1].marked && cells[2][2].marked) {
				if(cells[2][0].type == cells[2][1].type && cells[2][1].type == cells[2][2].type) {
					gameOver = true;
				}
			} 

			if(cells[0][0].marked && cells[1][0].marked && cells[2][0].marked) {
				if(cells[0][0].type == cells[1][0].type && cells[1][0].type == cells[2][0].type) {
					gameOver = true;
				}
			} 

			if(cells[0][1].marked && cells[1][1].marked && cells[2][1].marked) {
				if(cells[0][1].type == cells[1][1].type && cells[1][1].type == cells[2][1].type) {
					gameOver = true;
				}
			}

			if(cells[0][2].marked && cells[1][2].marked && cells[2][2].marked) {
				if(cells[0][2].type == cells[1][2].type && cells[1][2].type == cells[2][2].type) {
					gameOver = true;
				}
			}

			if(cells[0][0].marked && cells[1][1].marked && cells[2][2].marked) {
				if(cells[0][0].type == cells[1][1].type && cells[1][1].type == cells[2][2].type) {
					gameOver = true;
				}
			}

			if(cells[2][0].marked && cells[1][1].marked && cells[0][2].marked) {
				if(cells[2][0].type == cells[1][1].type && cells[1][1].type == cells[0][2].type) {
					gameOver = true;
				}
			}

			//	if all positions are occupied, then it is a draw
			if(positions >= 9) {
				draw = true;
			}
		}

		//	process events
		if(IsMouseButtonPressed(MouseButton.MOUSE_LEFT_BUTTON) ||
			IsMouseButtonPressed(MouseButton.MOUSE_RIGHT_BUTTON)) {
			mouseButtonPressed = true;
		}

		//	draw to screen
		BeginDrawing();
		ClearBackground(Color(0, 179, 255, 255));

		for(int i = 0; i < startPosV.length; i++) {
			DrawLineEx(startPosV[i], endPosV[i], 3, WHITE);
			DrawLineEx(startPosH[i], endPosH[i], 3, WHITE);
		}

		for(int i = 0; i < cells.length; i++) {
			for(int j = 0; j < cells[i].length; j++) {
				if(cells[i][j].marked) {
					DrawTextureRec(cells[i][j].t, cells[i][j].rect, 
					Vector2(cells[i][j].rect.x, cells[i][j].rect.y), WHITE);
				} 
			}
		}

		if(gameOver) {
			DrawRectangleRec(rectMuteScreen, Color(0, 0, 0, 160));
			DrawText("You won!", WIDTH/6, HEIGHT*2/5, 100, WHITE);
		} else if(draw) {
			DrawRectangleRec(rectMuteScreen, Color(0, 0, 0, 160));
			DrawText("It's a draw!", WIDTH/7, HEIGHT*2/5, 80, WHITE);
		}

		EndDrawing();
	}

	UnloadTexture(tnoughts);
	UnloadTexture(tcrosses);
	CloseWindow();
}


















