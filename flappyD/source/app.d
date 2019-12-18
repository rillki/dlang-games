import std.random: uniform;
import std.conv;

import raylib;

//	texture types
enum ObstacleType {
	GREEN, BLUE, GREY, RED, YELLOW, ORANGE, NONE
}

/*	obstacle struct:
	- creates an obstacle of random height
	- randomizes it's position
	- handles texture management
	- draws the obstacle to the screen
*/
struct Obstacle {
	Texture2D tex;

	Rectangle srect = Rectangle(0, 0, 0, 0);
	Vector2 pos = Vector2(0, 0);
	ObstacleType type = ObstacleType.NONE;

	bool growFromEarth;
	int height = 0;
	int blockSize = 0;
	int[6] body = 0;	// body of an obstacle, each entry with 1 is a block, 0 is nothing

	int windowWidth = 0;
	int windowHeight = 0;

	this(int winWidth, int winHeight, int block_size) {
		windowWidth = winWidth;
		windowHeight = winHeight;
		blockSize = block_size;

		growFromEarth = uniform(0, 2).to!bool;
		height = uniform(1, 6);
		pos = Vector2(400, 0);
		type = uniform(ObstacleType.GREEN, ObstacleType.NONE);

		tex = LoadTexture("res/tiles.png");
		switch(type) {	// cutting the required texture type from a texture tileset
			case ObstacleType.GREEN:
				srect = Rectangle(0, 0, blockSize, blockSize);
				break;
			case ObstacleType.BLUE:
				srect = Rectangle(blockSize, 0, blockSize, blockSize);
				break;
			case ObstacleType.GREY:
				srect = Rectangle(blockSize*ObstacleType.GREY, 0, blockSize, blockSize);
				break;
			case ObstacleType.RED:
				srect = Rectangle(blockSize*ObstacleType.RED, 0, blockSize, blockSize);
				break;
			case ObstacleType.YELLOW:
				srect = Rectangle(blockSize*ObstacleType.YELLOW, 0, blockSize, blockSize);
				break;
			case ObstacleType.ORANGE:
				srect = Rectangle(blockSize*ObstacleType.ORANGE, 0, blockSize, blockSize);
				break;
			default:
				break;
		}

		if(growFromEarth) {
			for(int i = height; i > 0; i--) {
				body[i] = 1;
			}
		} else {
			for(int i = 0; i < height; i++) {
				body[i] = 1;
			}
		}
	}

	~this() {
		UnloadTexture(tex);
	}

	void draw() {
		if(growFromEarth) {
			pos.y = windowHeight-height*blockSize;
			for(int i = height; i > 0; i--) {
				DrawTextureRec(tex, srect, Vector2(pos.x, windowHeight-i*blockSize), WHITE);
			}
		} else {
			for(int i = 0; i < height; i++) {
				DrawTextureRec(tex, srect, Vector2(pos.x, i*blockSize), WHITE);
			}
		}
	}
}

struct Sprite {
	Texture2D tex;
	Vector2 pos = Vector2(0, 0);

	Rectangle[2] srect;
}

void main() {
	immutable short WIDTH = 840;
	immutable short HEIGHT = 480;
	immutable short blockSize = 64;
	immutable short playerSize = 32;

	//	init
	InitWindow(WIDTH, HEIGHT, "Dlang Flappy D (bird)");
	SetTargetFPS(30);
	SetMouseScale(1.0, 1.0);

	Texture2D tbackground = LoadTexture("res/background.png");
	tbackground.width = WIDTH;
	tbackground.height = HEIGHT;

	Obstacle[15] obstacle;
	for(int i = 0; i < obstacle.length; i++) {
		obstacle[i] = Obstacle(WIDTH, HEIGHT, blockSize);
		if(i > 0) {
			obstacle[i].pos.x = obstacle[i-1].pos.x + uniform(132, 256); //	each obstacle has to be 132 to 256 away from the last one
		} else {
			obstacle[i].pos.x = WIDTH/2;
		}
	}

	Sprite sdbird;
	sdbird.tex = LoadTexture("res/dbird.png");
	sdbird.pos = Vector2(150, HEIGHT/4);
	sdbird.srect[0] = Rectangle(playerSize, 0, playerSize, playerSize);
	sdbird.srect[1] = Rectangle(0, 0, playerSize, playerSize);
	bool birdFly = false; // for animating the player sprite

	float gravity = 6;
	float jumpVelocity = 25;
	float velocity = 5;
	float da = 0.45; 		//	gravity acceleration
	float dv = jumpVelocity; 	//	delta velocity of player
	float dg = gravity; 		//	delta velocity of gravity

	Rectangle rmuteScreen = Rectangle(0, 0, WIDTH, HEIGHT);
	bool muteScreen = true;
	bool gameOver = false;
	bool gameWon = false;
	while (!WindowShouldClose()) {
		//	process events
		if(IsKeyDown(KeyboardKey.KEY_W) || IsKeyDown(KeyboardKey.KEY_UP) ||
			IsKeyDown(KeyboardKey.KEY_SPACE)) {
			if(muteScreen && !gameOver) {
				muteScreen = false;
			} else {
				dv = jumpVelocity;
			}
		}
		
		//	update
		if(!muteScreen) {
			sdbird.pos.y += dg - dv;
			if(sdbird.pos.y > HEIGHT) {
				gameOver = true;
			} else if(sdbird.pos.y < 0) {
				sdbird.pos.y = 1;
			}
			dv -= dg;
			dg += da;

			if(dv < 0) {
				dv = 0;
				birdFly = false;
			} else {
				dg = gravity;
				birdFly = true;
			}

			for(int i = 0; i < obstacle.length; i++) { // moving all of our obstacles towards the player
				obstacle[i].pos.x -= velocity;

				if(intersects(Vector2(0, 0), Vector2(WIDTH, HEIGHT), obstacle[i].pos, Vector2(blockSize, blockSize))) { // checking whether an obstacle is within the window bounds
					if(obstacle[i].growFromEarth) {
						if(intersects(sdbird.pos, Vector2(playerSize, playerSize), obstacle[i].pos, Vector2(blockSize, blockSize*obstacle[i].height))) { // if player hits an obstacle, game over
							gameOver = true;
						}
					} else {
						if(intersects(sdbird.pos, Vector2(playerSize, playerSize), obstacle[i].pos, Vector2(blockSize, blockSize*obstacle[i].height))) { // if player hits an obstacle, game over
							gameOver = true;
						}
					}
				}
			}

			if(sdbird.pos.x > obstacle[obstacle.length-1].pos.x + obstacle[obstacle.length-1].blockSize) { // if player has passed the last obstacle, the level is finished, gameWon = true
				gameWon = true;
			}
		}

		if(gameOver || gameWon) {
			muteScreen = true;
		}

		//	draw to screen
		BeginDrawing();
		ClearBackground(Color(0, 179, 255, 255));
		DrawTexture(tbackground, 0, 0, WHITE);

		for(int i = 0; i < obstacle.length; i++) {
			if(intersects(Vector2(0, 0), Vector2(WIDTH, HEIGHT), obstacle[i].pos, Vector2(blockSize, blockSize))) { // checking whether an obstacle is within the window bounds
				obstacle[i].draw();
			}
		}
		DrawTextureRec(sdbird.tex, sdbird.srect[birdFly], sdbird.pos, WHITE);

		if(muteScreen) {
			if(gameOver) {
				DrawRectangle(rmuteScreen.x.to!int, rmuteScreen.y.to!int, rmuteScreen.width.to!int, rmuteScreen.height.to!int, Color(0, 0, 0, 180));
				DrawText("You lost!", (WIDTH/3.5).to!int, HEIGHT/3, 90, WHITE);
			} else if(gameWon) {
				DrawRectangle(rmuteScreen.x.to!int, rmuteScreen.y.to!int, rmuteScreen.width.to!int, rmuteScreen.height.to!int, Color(0, 0, 0, 180));
				DrawText("You won!", WIDTH/4, HEIGHT/3, 90, WHITE);
			} else {
				DrawRectangle(rmuteScreen.x.to!int, rmuteScreen.y.to!int, rmuteScreen.width.to!int, rmuteScreen.height.to!int, Color(0, 0, 0, 180));
				DrawText("Press SPACE, W or", WIDTH/24, HEIGHT/4, 64, WHITE);
				DrawText("UP keys to play!", WIDTH/3, HEIGHT/2, 64, WHITE);
			}
		}

		EndDrawing();
	}

	UnloadTexture(sdbird.tex);
	UnloadTexture(tbackground);
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








