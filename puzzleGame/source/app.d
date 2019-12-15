import std.random: uniform;
import raylib;

struct Sprite {
	Rectangle srect;
	Vector2 pos;

	bool occupied = true;
}

struct Vector2i {
	int x = 0;
	int y = 0;
}

void main() {
	immutable short WIDTH = 384;
	immutable short HEIGHT = 384;
	immutable short SPRITE_SIZE = 128;

	//	init
	InitWindow(WIDTH, HEIGHT, "Dlang Puzzle Game");
	SetTargetFPS(30);
	SetMouseScale(1.0, 1.0);

	//	loading our image
	Texture2D tpuzzle = LoadTexture("res/puzzle.png");
	tpuzzle.width = WIDTH;
	tpuzzle.height = HEIGHT;

	//	divide the image into 9 pieces
	Sprite[3][3] sprite;
	Vector2i index = Vector2i(sprite.length-1, sprite.length-1);
	sprite[index.x][index.y].occupied = false;
	for(int i = 0; i < sprite.length; i++) {
		for(int j = 0; j < sprite[i].length; j++) {
			if(sprite[i][j].occupied) {
				sprite[i][j].srect.width = sprite[i][j].srect.height = SPRITE_SIZE;
				sprite[i][j].srect.x = SPRITE_SIZE*j;
				sprite[i][j].srect.y = SPRITE_SIZE*i;

				sprite[i][j].pos.x = SPRITE_SIZE*j;
				sprite[i][j].pos.y = SPRITE_SIZE*i;
			}
		}
	}

	Rectangle rmuteScreen = Rectangle(0, 0, WIDTH, HEIGHT);

	bool randomize = true;
	while(!WindowShouldClose()) {
		//	process events and update
		if(randomize) {
			if(IsKeyPressed(KeyboardKey.KEY_SPACE)) {
				randomize = false;
			}

			//	mix the puzzle pieces
			int action = uniform(0, 4);
			if(action == 1) {
				moveUp(index, sprite, SPRITE_SIZE);
			} else if(action == 2) {
				moveDown(index, sprite, SPRITE_SIZE);
			} else if(action == 3) {
				moveLeft(index, sprite, SPRITE_SIZE);
			} else {
				moveRight(index, sprite, SPRITE_SIZE);
			}
		}

		if(IsKeyPressed(KeyboardKey.KEY_RIGHT)) {
			moveRight(index, sprite, SPRITE_SIZE);
		} else if(IsKeyPressed(KeyboardKey.KEY_LEFT)) {
			moveLeft(index, sprite, SPRITE_SIZE);
		} else if(IsKeyPressed(KeyboardKey.KEY_DOWN)) {
			moveDown(index, sprite, SPRITE_SIZE);
		} else if(IsKeyPressed(KeyboardKey.KEY_UP)) {
			moveUp(index, sprite, SPRITE_SIZE);
		}

		// draw to screen
		BeginDrawing();
		ClearBackground(Color(255, 255, 255, 255));

		for(int i = 0; i < sprite.length; i++) {
			for(int j = 0; j < sprite[i].length; j++) {
				if(sprite[i][j].occupied) {
					DrawTextureRec(tpuzzle, sprite[i][j].srect, sprite[i][j].pos, WHITE);
				}
			}
		}

		if(randomize) {
			DrawRectangleRec(rmuteScreen, Color(0, 0, 0, 180));
			DrawText("Press Space to play!", (WIDTH/16), HEIGHT/3, 32, WHITE);
		}	

		EndDrawing();
	}

	UnloadTexture(tpuzzle);
	CloseWindow();
}

void moveRight(ref Vector2i index, ref Sprite[3][3] sprite, short sprite_size) {
	if(index.x > 0) {
		Sprite temp = sprite[index.y][index.x-1];
		sprite[index.y][index.x-1] = sprite[index.y][index.x];
		sprite[index.y][index.x] = temp;

		sprite[index.y][index.x].pos.x += sprite_size;
		sprite[index.y][index.x-1].pos.x -= sprite_size;
		index.x -= 1;
	}
}

void moveLeft(ref Vector2i index, ref Sprite[3][3] sprite, short sprite_size) {
	if(index.x < sprite.length-1) {
		Sprite temp = sprite[index.y][index.x+1];
		sprite[index.y][index.x+1] = sprite[index.y][index.x];
		sprite[index.y][index.x] = temp;

		sprite[index.y][index.x].pos.x -= sprite_size;
		sprite[index.y][index.x+1].pos.x += sprite_size;
		index.x += 1;
	}
}

void moveUp(ref Vector2i index, ref Sprite[3][3] sprite, short sprite_size) {
	if(index.y < sprite.length-1) {
		Sprite temp = sprite[index.y+1][index.x];
		sprite[index.y+1][index.x] = sprite[index.y][index.x];
		sprite[index.y][index.x] = temp;

		sprite[index.y][index.x].pos.y -= sprite_size;
		sprite[index.y+1][index.x].pos.y += sprite_size;
		index.y += 1;
	}
}

void moveDown(ref Vector2i index, ref Sprite[3][3] sprite, short sprite_size) {
	if(index.y > 0) {
		Sprite temp = sprite[index.y-1][index.x];
		sprite[index.y-1][index.x] = sprite[index.y][index.x];
		sprite[index.y][index.x] = temp;

		sprite[index.y][index.x].pos.y += sprite_size;
		sprite[index.y-1][index.x].pos.y -= sprite_size;
		index.y -= 1;
	}
}


