import std.stdio: writeln, write;
import std.conv;
import std.random: uniform;

import raylib;

struct Shapes {
	int[6][6] I = [
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 1, 0],
		[0, 0, 0, 0, 1, 0],
		[0, 0, 0, 0, 1, 0],
		[0, 0, 0, 0, 1, 0],
		[0, 0, 0, 0, 0, 0]
	];

	int[6][6] O = [
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 1, 1, 0, 0],
		[0, 0, 1, 1, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0]
	];

	int[6][6] T = [
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 1, 0, 0],
		[0, 0, 1, 1, 0, 0],
		[0, 0, 0, 1, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0]
	];

	int[6][6] J = [
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 1, 0, 0],
		[0, 0, 0, 1, 0, 0],
		[0, 0, 1, 1, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0]
	];

	int[6][6] L = [
		[0, 0, 0, 0, 0, 0],
		[0, 0, 1, 0, 0, 0],
		[0, 0, 1, 0, 0, 0],
		[0, 0, 1, 1, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0]
	];

	int[6][6] S = [
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 1, 1, 0],
		[0, 0, 1, 1, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0]
	];

	int[6][6] Z = [
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 1, 1, 0, 0],
		[0, 0, 0, 1, 1, 0],
		[0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0]
	];
}

struct Tetromino {
	int[6][6] matrix;
	int x = 0;
	int y = 0;
}

void main() {
	immutable short WIDTH = 320;
	immutable short HEIGHT = 480;
	immutable short BLOCK_SIZE = 16;
	immutable short BOARD_WIDTH = 20;
	immutable short BOARD_HEIGHT = 30;

	int[BOARD_WIDTH][BOARD_HEIGHT] board = 0;

	//	init
	InitWindow(WIDTH, HEIGHT, "Dlang Tetris");
	SetTargetFPS(15);
	SetMouseScale(1.0, 1.0);

	Shapes s;
	Tetromino tetromino;
	generateTetromino(tetromino, s);

	Texture2D tbackground = LoadTexture("res/background.png");
	tbackground.width = WIDTH;
	tbackground.height = HEIGHT;

	Texture2D ttetromino = LoadTexture("res/white.png");
	Texture2D ttetrominoMatrix = LoadTexture("res/green.png");

	Rectangle rtop = Rectangle(0, 0, WIDTH, BLOCK_SIZE*2);
	Rectangle rmuteScreen = Rectangle(0, 0, WIDTH, HEIGHT);
	bool muteScreen = true;
	bool gameOver = false;

	int indexL = 0;
	int indexR = 0;
	float time = 0;
	bool tetromino_copy = false;
	while (!WindowShouldClose()) {
		if(!muteScreen) {
			//	game logic
			//	checking whether tetromino has reached the bottom of the board, if so, copy it to the board
			for(int i = tetromino.matrix.length-1; i > 0; i--) {
				for(int j = tetromino.matrix.length-1; j > 0; j--) {
					if(tetromino.matrix[i][j] && tetromino.y+i > BOARD_HEIGHT-2) {
						tetromino_copy = true;
						break;
					}
				}

				if(tetromino_copy) {
					break;
				}
			}

			//	checking whether tetromino collides with other tetromino peices
			for(int i = tetromino.matrix.length-1; i > 0; i--) {
				for(int j = 0; j < tetromino.matrix[i].length; j++) {
					if(tetromino.y+i+1 < BOARD_HEIGHT) {
						if(tetromino.matrix[i][j]) {
							if(board[tetromino.y+i+1][tetromino.x+j]) {
								tetromino_copy = true;
								break;
							}
						}
					}
				}
			}

			//	copying tetromino to the board
			if(tetromino_copy) {
				for(int i = tetromino.matrix.length-1; i > 0; i--) {
					for(int j = 0; j < tetromino.matrix[i].length; j++) {
						if(tetromino.matrix[i][j]) {
							while(tetromino.y+i >= BOARD_HEIGHT) { tetromino.y--; }
							board[tetromino.y+i][tetromino.x+j] = 1;
						}
					}
				}

				generateTetromino(tetromino, s);
				tetromino_copy = false;
			}

			//	checking whether rows of the board are completely filled, if so, delete the row
			int temp = board.length-1;
			for(int i = temp; i > 0; i--) {
				int count = 0;
				for(int j = 0; j < board[i].length; j++) {
					if(board[i][j] == 1) {
						count++;
					}

					board[temp][j] = board[i][j];
				}

				if(count < BOARD_WIDTH) {
					temp--;
				}
			}

			//	process events
			if(IsKeyDown(KeyboardKey.KEY_LEFT)) {
				if(tetromino.x+indexL > 0) {
					if(!board[tetromino.y][tetromino.x+indexL-1]) { //	tetromino cannot be moved to the left if the board is filled on the left
						tetromino.x--;
					}
				}
			} else if(IsKeyDown(KeyboardKey.KEY_RIGHT)) {
				if(tetromino.x+indexR+1 < BOARD_WIDTH) {
					if(!board[tetromino.y][tetromino.x+indexR+1]) { //	tetromino cannot be moved to the right if the board is filled on the right
						tetromino.x++;
					}
				}
			}else if(IsKeyDown(KeyboardKey.KEY_DOWN)) {
				tetromino.y++;
			} else if(IsKeyPressed(KeyboardKey.KEY_SPACE)) {
				matrixTranspose(tetromino);
			}

			//	move tetromino down
			time += GetFrameTime();
			if(time >= 0.5) {
				tetromino.y++;
				time = 0;
			}

			//	checking bounds, tetromino has to stay within the bounds of the board
			indexL = 0;
			for(int j = 0; j < tetromino.matrix[0].length; j++) {
				for(int i = 0; i < tetromino.matrix.length; i++) {
					if(tetromino.matrix[i][j]) {
						indexL = j;	//	we need to find the index of a colomn containing a tetromino block. For example, shape Z: colomn containing first tetromino block is 2
						break;		//	since we do do not display the entire matrix, we need a reference point: indexL
					}
				}

				if(indexL) {
					break;
				}
			}

			while(tetromino.x+indexL < 0) {	//	if tetromino position is negative (not the matrix position: matrix position is x, tetromino position is x+indexL)
				tetromino.x++;				//	we adjust tetromino position
			}

			indexR = 0;
			for(int j = tetromino.matrix[0].length-1; j > 0; j--) {
				for(int i = 0; i < tetromino.matrix.length; i++) {
					if(tetromino.matrix[i][j]) {
						indexR = j;
						break;
					}
				}

				if(indexR) {
					break;
				}
			}

			while(tetromino.x+indexR > BOARD_WIDTH-1) {	//	if tetromino position is greater than board width, we adjust the position <=width
				tetromino.x--;
			}

			for(int i = 0; i < board[2].length; i++) {	//	checking whether tetrominos have reached the top, if so, game is over
				if(board[2][i]) {
					muteScreen = gameOver = true;
					break;
				}
			}
		}

		if(IsKeyPressed(KeyboardKey.KEY_P) && !gameOver) {
			muteScreen = !muteScreen;
		}

		//	draw to screen
		BeginDrawing();
		ClearBackground(Color( 204, 204, 255, 255 ));
		DrawTexture(tbackground, 0, 0, WHITE);

		for(int i = 0; i < tetromino.matrix.length; i++) {
			for(int j = 0; j < tetromino.matrix[i].length; j++) {
				if(tetromino.matrix[i][j]) {
					DrawTexture(ttetrominoMatrix, (tetromino.x+j)*BLOCK_SIZE, (tetromino.y+i)*BLOCK_SIZE, WHITE);
				}
			}
		}

		for(int i = 0; i < board.length; i++) {
			for(int j = 0; j < board[i].length; j++) {
				if(board[i][j]) {
					DrawTexture(ttetromino, j*BLOCK_SIZE, i*BLOCK_SIZE, WHITE);
				}
			}
		}

		DrawRectangleRec(rtop, Color(0, 0, 0, 100));

		if(muteScreen) {
			DrawRectangleRec(rmuteScreen, Color(0, 0, 0, 180));

			if(gameOver) {
				DrawText("Game over!", WIDTH/10, HEIGHT/3, 48, WHITE);
			} else {
				DrawText("Welcome!", (WIDTH/3.5).to!int, HEIGHT/7, 32, WHITE);
				DrawText("Arrow keys - to move around", WIDTH/10, HEIGHT*2/7, 19, WHITE);
				DrawText("Space - to rotate", (WIDTH/4.5).to!int, HEIGHT*3/7, 20, WHITE);
				DrawText("P - to pause or play!", (WIDTH/5.7).to!int, HEIGHT*4/7, 20, WHITE);
			}
		}

		EndDrawing();
	}

	UnloadTexture(ttetrominoMatrix);
	UnloadTexture(ttetromino);
	UnloadTexture(tbackground);
	CloseWindow();
}

void generateTetromino(ref Tetromino t, Shapes s) {
	int rnum = uniform(0, 7);
	switch(rnum) {
		case 1:
			t.matrix = s.O;
			break;
		case 2:
			t.matrix = s.T;
			break;
		case 3:
			t.matrix = s.J;
			break;
		case 4:
			t.matrix = s.L;
			break;
		case 5:
			t.matrix = s.S;
			break;
		case 6:
			t.matrix = s.Z;
			break;
		default:
			t.matrix = s.I;
			break;
	}

	t.x = 5;
	t.y = 0;
}

void matrixTranspose(ref Tetromino t) {	//	rotating the matrix
	int[6][6] matrixT = 0;
	int index = 0;

	for(int i = 0; i < t.matrix.length; i++) {
		for(int j = 0; j < t.matrix[i].length; j++) {
			matrixT[i][j] = t.matrix[j][i];
		}
	}

	t.matrix = matrixT;
}
