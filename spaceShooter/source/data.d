module data;

import raylib;
import std.string: toStringz;

enum GameState { MENU, PLAY, EXIT }
enum StarshipType { PALADIN, SPECTER, STARHAMMER }
enum EntityState { STATIONARY, MOVING, SHOOTING, EXPLODING, DESTROYED }

immutable int WIDTH = 1080;
immutable int HEIGHT = 640;

// common functions
interface Entity {
	public void processEvents();					// processing events
	public void update();						// updating game logic
	public void render();						// drawing to the window

	public int getActualSpriteWidth();				// getting the width of a sprite (textures have their own width)
	public int getActualSpriteHeight();				// getting the height of a sprite (textures have their own height)
	public void setPos(Vector2 pos);				// setting sprite position
	public Vector2 getPos();					// getting sprite position
	public void forceBulletRemove(int i);
	public bool shieldOn();

	public Rectangle getEntity(int i);				// getting a copy of rectangle entity out of an array of bullets or enemies
	public ulong getEntityLength();					// getting the length of entity array

	private void move(float x, float y, EntityState state);		// moving the sprite
}

// basic data type for handling texture and drawing it
struct Sprite {
	Texture2D tex;							// main texture
	Vector2 pos;							// position
	Rectangle[] srect;						// texture frames, used for animation

	EntityState estate = EntityState.STATIONARY;

	int actualWidth = 0;						// sprite width, texture may include multiple sprites
	int actualHeight = 0;						// sprite height, texture may include multiple sprites
	int currentFrame = 0;						// current frame drawn to the screen
}

// mouse collision
bool checkMouseCollision(float mouseX, float mouseY, float x, float y, int w, int h) {
	if(mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
		return true;
	}

	return false;
}
