import std.stdio: writeln, write;
import std.random: uniform;

import raylib;

enum SpriteType {
	HIDDEN, FLAGGED, MINE, EMPTY, 
	ONE, TWO, THREE, FOUR, 
	FIVE, SIX, SEVEN, EIGHT, 
	MAX_SIZE
}

void main() {
	immutable short WIDTH = 320;
	immutable short HEIGHT = 320;
	immutable short BOARD_SIZE = 20;
	immutable short SPRITE_SIZE = 16;

	int[BOARD_SIZE][BOARD_SIZE] hiddenGrid = SpriteType.EMPTY;
	int[BOARD_SIZE][BOARD_SIZE] playerGrid = SpriteType.HIDDEN;

	//	init
	InitWindow(WIDTH, HEIGHT, "Dlang Minesweeper");
	SetTargetFPS(30);
	SetMouseScale(1.0, 1.0);

	Texture2D tminesweeper = LoadTexture("res/minesweeper.png");

	//	setting mines at random coordinates
	for(int i = 0; i < hiddenGrid.length; i++) {
		for(int j = 0; j < hiddenGrid[i].length; j++) {
			hiddenGrid[i][j] = uniform(2, SpriteType.MAX_SIZE);

			if(hiddenGrid[i][j] != SpriteType.MINE) {
				hiddenGrid[i][j] = SpriteType.EMPTY;
			}
		}
	}

	//	adding hints to minefield
	for(int i = 1; i <= hiddenGrid.length-2; i++) {
		for(int j = 1; j <= hiddenGrid[i].length-2; j++) {
			if (hiddenGrid[i][j] == SpriteType.MINE) {
				continue;
			}

			if (hiddenGrid[i+1][j] == SpriteType.MINE) {
				hiddenGrid[i][j]++;
		    }

		    if (hiddenGrid[i][j+1] == SpriteType.MINE) {
				hiddenGrid[i][j]++;
		    }

		    if (hiddenGrid[i-1][j] == SpriteType.MINE) {
				hiddenGrid[i][j]++;
		    }

		    if (hiddenGrid[i][j-1] == SpriteType.MINE) {
		    	hiddenGrid[i][j]++;
		    } 

		    if (hiddenGrid[i+1][j+1] == SpriteType.MINE) {
				hiddenGrid[i][j]++;
		    }  

		    if (hiddenGrid[i-1][j-1] == SpriteType.MINE) {
				hiddenGrid[i][j]++;
		    }

		    if (hiddenGrid[i-1][j+1] == SpriteType.MINE) {
				hiddenGrid[i][j]++;
		    }

		    if (hiddenGrid[i+1][j-1] == SpriteType.MINE) {
				hiddenGrid[i][j]++;
		    }
		}
	}

	//	cutting individual sprites from a tileset
	Rectangle[SpriteType.MAX_SIZE] srect;
	for(int i = 0; i < srect.length; i++) {
		srect[i].width = srect[i].height = SPRITE_SIZE;
		srect[i].x = i*SPRITE_SIZE;
		srect[i].y = 0;
	}

	while (!WindowShouldClose()) {
		//	process events
		Vector2 mousePos = GetMousePosition();

		//	if left mouse button is pressed, the hidden cell is revealed
		if(IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT)) {
			int getOut = false;
			for(int i = 0; i < playerGrid.length; i++) {
				for(int j = 0; j < playerGrid[i].length; j++) {
					if(intersects(mousePos, Vector2(i*SPRITE_SIZE, j*SPRITE_SIZE), SPRITE_SIZE)) {
						//	if player clicks on the mine => game over, the board is revealed
						if(hiddenGrid[i][j] == SpriteType.MINE) {
							playerGrid = hiddenGrid;
							getOut = true;
							break;
						}

						playerGrid[i][j] = hiddenGrid[i][j];

						getOut = true;
						break;
					}
				}

				if(getOut) {
					break;
				}
			}
		} else if(IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_RIGHT)) {	//	player should be able to flag his guess on where the mine is located
			int getOut = false;
			for(int i = 0; i < playerGrid.length; i++) {
				for(int j = 0; j < playerGrid[i].length; j++) {
					if(intersects(mousePos, Vector2(i*SPRITE_SIZE, j*SPRITE_SIZE), SPRITE_SIZE)) {
						//	player can only flag hidden cells
						if(playerGrid[i][j] == SpriteType.HIDDEN) {
							playerGrid[i][j] = SpriteType.FLAGGED;

							getOut = true;
							break;
						}
					}
				}

				if(getOut) {
					break;
				}
			}
		}

		//	draw to screen
		BeginDrawing();
		ClearBackground(Color(0, 179, 255, 255));

		for(int i = 0; i < hiddenGrid.length; i++) {
			for(int j = 0; j < hiddenGrid[i].length; j++) {
				DrawTextureRec(tminesweeper, srect[playerGrid[i][j]], Vector2(i*SPRITE_SIZE, j*SPRITE_SIZE), Colors.WHITE);
			}
		}

		EndDrawing();
	}

	UnloadTexture(tminesweeper);
	CloseWindow();
}

//	checking for collision between the mousePos and grid cells
bool intersects(Vector2 mousePos, Vector2 rectPos, int size) {
	if(mousePos.x > rectPos.x && mousePos.y > rectPos.y &&
		mousePos.x < rectPos.x+size && mousePos.y < rectPos.y+size) {
		return true;
	}

	return false;
}






