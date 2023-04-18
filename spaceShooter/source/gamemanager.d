module gamemanager;

import raylib;
import std.string: toStringz;		// converting a Dlang string to a C string
import std.conv: to;				// converting data types to!int(some_Variable)

import data;						// common data throughout the game
import play;						// gameplay manager
import resmanager;					// resource manager

class gameManager {
	int radius = 81;
	float distance = 0;

	GameState gstate = GameState.MENU;
	StarshipType shipType = StarshipType.PALADIN;

	Texture2D tbackground;			// main menu background image

	Vector2 mousePos;			// for tracking mouse position
	Vector2 textPos;			// main menu text position ("play", "exit")
	Vector2 circleSelectorPos;		// ship selector
	Sprite ships;				// enemy ship

	Rectangle rmenuSelector;		// main menu option selector ("play", "exit")

	// initialization
	this(string title) {
		InitWindow(WIDTH, HEIGHT, title.toStringz);
		SetTargetFPS(60);
		SetMouseScale(1.0, 1.0);

		// initialize resource manager and load all texture from a file
		ResManager!Texture2D.getInstance.initAndLoadFromFile("loadTextures.txt", &loadTexture, &unloadTexture);

		tbackground = ResManager!Texture2D.getInstance.get("background");			// retrieving a texture
		tbackground.width = WIDTH;
		tbackground.height = HEIGHT;

		ships.tex = ResManager!Texture2D.getInstance.get("ships");
		ships.actualWidth = ships.actualHeight = 128;
		ships.srect ~= Rectangle(0, 0, ships.actualWidth, ships.actualHeight);
		ships.srect ~= Rectangle(ships.actualWidth, 0, ships.actualWidth, ships.actualHeight);
		ships.srect ~= Rectangle(ships.actualWidth*2, 0, ships.actualWidth, ships.actualHeight);
		ships.pos = Vector2(WIDTH/7, HEIGHT*2.6/4);
		distance = WIDTH/3.5;

		circleSelectorPos = Vector2(ships.pos.x+ships.actualWidth/2, ships.pos.y+ships.actualHeight/2);
		textPos = Vector2(WIDTH/2, HEIGHT/6);
		rmenuSelector = Rectangle(0, textPos.y, WIDTH, 90);
	}

	~this() {
		CloseWindow();
	}

	// entry point of the game
	public void run() {
		while(gstate != GameState.EXIT) {
			if(gstate == GameState.MENU) {
				processEvents();
				update();
				render();
			} else if(gstate == GameState.PLAY) {
				Play play = new Play(gstate, shipType);		// if PLAY, create a Play object, destroy when over =>
				gstate = execute(play);
				object.destroy(play);
			}
		}
	}

	private void processEvents() {
		if(WindowShouldClose()) {					// close the window event
			gstate = GameState.EXIT;
		} else if(IsKeyPressed(KeyboardKey.KEY_SPACE)) {		// if space was pressed, init gameplay
			gstate = GameState.PLAY;
		} else if(IsKeyPressed(KeyboardKey.KEY_ENTER)) {		// if space was pressed, init gameplay, otherwise quit
			if(rmenuSelector.y == textPos.y) {
				gstate = GameState.PLAY;
			} else {
				gstate = GameState.EXIT;
			}
		} else if(IsKeyPressed(KeyboardKey.KEY_UP)) {			// move menu selector up
			rmenuSelector.y = textPos.y;
		} else if(IsKeyPressed(KeyboardKey.KEY_DOWN)) {			// move menu selector down
			rmenuSelector.y = textPos.y*2.3 - (rmenuSelector.height - 81);
		} else if(IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_LEFT) || IsMouseButtonPressed(MouseButton.MOUSE_BUTTON_RIGHT)) {
			if(mousePos.y > textPos.y && mousePos.y < textPos.y + 81) {
				gstate = GameState.PLAY;			// if main menu -> "play" was pressed
			} else if(mousePos.y > textPos.y*2.3 && mousePos.y < textPos.y*2.3 + 81) {
				gstate = GameState.EXIT;			// if main menu -> "exit" was pressed
			}
		}
	}

	private void update() {
		mousePos = GetMousePosition();

		// selecting a ship
		for(int i = 0; i < ships.srect.length; i++) {
			if(checkMouseCollision(mousePos.x, mousePos.y, ships.pos.x + i*distance, ships.pos.y, ships.actualWidth, ships.actualHeight)) {
				circleSelectorPos = Vector2(ships.pos.x+ships.actualWidth/2 + i*distance, ships.pos.y+ships.actualHeight/2);
				shipType = i.to!StarshipType;
				break;
			}
		}

		// adjusting the position of the menu selector
		if(mousePos.y > textPos.y && mousePos.y < textPos.y + 81) {
			rmenuSelector.y = textPos.y;
		} else if(mousePos.y > textPos.y*2.3 && mousePos.y < textPos.y*2.3 + 81) {
			rmenuSelector.y = textPos.y*2.3 - (rmenuSelector.height - 81);
		}
	}

	private void render() {
		BeginDrawing();
		ClearBackground(Colors.WHITE);
		DrawTexture(tbackground, 0, 0, Colors.WHITE); 	// background
		DrawFPS(10, 10);			// drawing fps

		// drawing ship selector
		DrawCircleV(circleSelectorPos, radius, Color(180, 180, 180, 164));
		for(int i = 0; i < ships.srect.length; i++) {
			// drawing ships
			DrawTextureRec(ships.tex, ships.srect[i], Vector2(ships.pos.x + i*distance, ships.pos.y), Colors.WHITE);
		}

		// drawing menu selector
		DrawRectangleRec(rmenuSelector, Color(0, 0, 0, 164));
		DrawText("Play", textPos.x.to!int-90, textPos.y.to!int, 81, Colors.WHITE);
		DrawText("Exit", textPos.x.to!int-80, (2.3*textPos.y).to!int, 81, Colors.WHITE);

		// drawing ships' names underneath the ship texture
		DrawText("PALADIN", ships.pos.x.to!int, (ships.pos.y + ships.actualHeight*1.2).to!int, 30, Colors.WHITE);
		DrawText("SPRECTER", (ships.pos.x + distance).to!int - 20, (ships.pos.y + ships.actualHeight*1.2).to!int, 30, Colors.WHITE);
		DrawText("STARHAMMER", (ships.pos.x + distance*2).to!int - 45, (ships.pos.y + ships.actualHeight*1.2).to!int, 30, Colors.WHITE);

		EndDrawing();
	}
}
