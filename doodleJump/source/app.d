import std.random: uniform;
import std.conv;

import raylib;

struct Index {
	int index = 0;

	bool moveLeft = false;
}

void main() {
	immutable int WIDTH = 480;
	immutable int HEIGHT = 640;

	//	init
	InitWindow(WIDTH, HEIGHT, "Dlang Doodle Jump");
	SetTargetFPS(60);
	SetMouseScale(1.0, 1.0);

	Texture2D tbackground = LoadTexture("res/sky.png");
	tbackground.width = WIDTH;
	tbackground.height = HEIGHT;

	Texture2D tpaddles = LoadTexture("res/paddles.png");
	Vector2[100] paddlesPos;
	for(int i = 0; i < paddlesPos.length; i++) {
		paddlesPos[i].x = uniform(0, WIDTH - tpaddles.width/2);

		if(i > 0) {
			paddlesPos[i].y = paddlesPos[i-1].y - uniform(128, 200);
		} else {
			paddlesPos[0].y = HEIGHT - HEIGHT/5;
		}
	}

	//	randomly select index of paddles that will be moving
	Index[16] index;
	for(int i = 0; i < index.length; i++) {
		index[i].index = uniform(0, 100);
	}

	//	cutting individual sprites from a tileset
	Rectangle[2] srect;
	srect[0] = Rectangle(0, 0, 64, 8);
	srect[1] = Rectangle(64, 0, 64, 8);

	Texture2D tdoodlejump = LoadTexture("res/doodlejump.png");
	Vector2 doodlePos = Vector2(WIDTH/2-tdoodlejump.width/2, HEIGHT/2);

	int movingSpeed = 9;
	int fallingSpeed = 9;

	immutable float gravity = 1.5;	//	gravity
	immutable float dy = 15;	//	constant jumping velocity
	float jump = dy;		//	delta jumping velocity
	float da = 0;			//	acceleration

	Rectangle rmuteScreen = Rectangle(0, 0, WIDTH, HEIGHT);
	bool muteScreen = false;
	bool gameOver = false;
	while(!WindowShouldClose()) {
		if(!muteScreen) {
			//	process events
			if(IsKeyDown(KeyboardKey.KEY_LEFT) ||
				IsKeyDown(KeyboardKey.KEY_A)) {
				doodlePos.x -= movingSpeed;

				// a smooth transition
				if(doodlePos.x + tdoodlejump.width < 0) {	//	if the player jumps to the left border of the window, move the player to the right border
					doodlePos.x = WIDTH;
				}
			} else if(IsKeyDown(KeyboardKey.KEY_RIGHT) || 
				IsKeyDown(KeyboardKey.KEY_D)) {
				doodlePos.x += movingSpeed;

				// a smooth transition
				if(doodlePos.x > WIDTH) {			//	if the player jumps to the right border of the window, move the player to the left border
					doodlePos.x = -tdoodlejump.width;
				}
			} else if(IsKeyDown(KeyboardKey.KEY_SPACE)) {		//	additional acceleration (optional, could be removed)
				jump += gravity/2;
				da += 0.1;
			}

			//	update
			//	if the player lands on one of the paddles, then jump
			for(int i = 0; i < paddlesPos.length; i++) {
				if(intersects(Vector2(doodlePos.x, doodlePos.y), Vector2(tdoodlejump.width, tdoodlejump.height),
					paddlesPos[i], Vector2(64, 8))) {
					da += 0.05;		// player recieves acceleration when jumping
					jump = dy + da;
					break;
				}
			}

			//	move paddles down the screen e. g. player jumps
			for(int i = 0; i < paddlesPos.length; i++) {
				paddlesPos[i].y -= fallingSpeed;

				if(jump) {
					paddlesPos[i].y += jump;
				}
			}

			//	checking whether the player has reached the top of the game
			for(int i = 0; i < paddlesPos.length; i++) {
				if(paddlesPos[i].y > HEIGHT/1.5) {
					muteScreen = true;
				} else {
					muteScreen = false;
					break;
				}
			}

			// checking whether the player has lost the game by falling down
			for(int i = 0; i < paddlesPos.length; i++) {
				if(paddlesPos[i].y < HEIGHT/2) {
					gameOver = true;
				} else {
					gameOver = false;
					break;
				}
			}

			if(gameOver) {
				muteScreen = true;
			}

			jump -= gravity;	//	gravity affects player's jumping velocity
			if (jump < 0) {
				jump = 0;
				da = 18;
			}

			//	move paddles
			for(int i = 0; i < index.length; i++) {
				if(index[i].moveLeft) {
					paddlesPos[index[i].index].x -= movingSpeed/3;

					if(paddlesPos[index[i].index].x < 0) {
						index[i].moveLeft = false;
					}
				} else {
					paddlesPos[index[i].index].x += movingSpeed/2;

					if(paddlesPos[index[i].index].x + tpaddles.width/2 > WIDTH) {
						index[i].moveLeft = true;
					}
				}
			}
		}

		//	draw to screen
		BeginDrawing();
		ClearBackground(Color(255, 255, 255, 255));
		DrawTexture(tbackground, 0, 0, WHITE);

		DrawTexture(tdoodlejump, doodlePos.x.to!int, doodlePos.y.to!int, WHITE);
		for(int i = 0; i < paddlesPos.length; i++) {
			if(intersects(paddlesPos[i], Vector2(tpaddles.width/2, tpaddles.height), Vector2(0, 0), Vector2(WIDTH, HEIGHT))) {
				if(i%2 == 0) {
					DrawTextureRec(tpaddles, srect[0], paddlesPos[i], WHITE);
				} else {
					DrawTextureRec(tpaddles, srect[1], paddlesPos[i], WHITE);
				}
			}
		}

		if(muteScreen) {
			DrawRectangle(rmuteScreen.x.to!int, rmuteScreen.y.to!int, 
				rmuteScreen.width.to!int, rmuteScreen. height.to!int, 
				Color(0, 0, 0, 185));

			if(gameOver) {
				DrawText("You Lost!", WIDTH/9, HEIGHT/3, 81, WHITE);
			} else {
				DrawText("You Won!", WIDTH/7, HEIGHT/3, 81, WHITE);
			}
		}

		EndDrawing();
	}

	UnloadTexture(tbackground);
	UnloadTexture(tpaddles);
	UnloadTexture(tdoodlejump);
	CloseWindow();
}

// collision between two sprites
bool intersects(Vector2 playerPos, Vector2 playerSize, Vector2 rectanglePos, Vector2 rectangleSize) {
	if(playerPos.x + playerSize.x > rectanglePos.x && 
		playerPos.x < rectanglePos.x + rectangleSize.x &&
		playerPos.y+playerSize.y > rectanglePos.y &&
		playerPos.y < rectanglePos.y+rectangleSize.y) {
		return true;
	}

	return false;
}





