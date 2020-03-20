module starship;

import raylib;
import std.algorithm: remove;
import std.conv: to;

import data;
import texturemanager;

struct Bullet {
	Vector2 pos;			// bullet position
	Rectangle[] srect;		// bullet frames

	double time = 0;
	double speed = 0;
	int actualWidth = 0;
	int actualHeight = 0;
	int currentFrame = 0;

	this(int awidth, int aheight, double speed, int frames, Vector2 playerPos, Vector2 playerSize) {
		actualWidth = awidth;
		actualHeight = aheight;
		this.speed = speed*1.2;

		pos.x = playerPos.x + playerSize.x/2 - actualWidth/2;
		pos.y = playerPos.y + playerSize.y/2 - actualHeight/2;

		for(int i = 0; i < frames; i++) {
			srect ~= Rectangle(actualWidth*i, 0, actualWidth, actualHeight);
		}
	}

	~this() {}

	void move() {
		// animating the bullet
		time += GetFrameTime();
    		if(time > 0.15) {
    			currentFrame++;
			if(currentFrame > srect.length-1) {
				currentFrame = 0;
			}

    			time = 0;
    		}

		// moving bullet accros the screen
    		pos.y -= speed;
	}

	bool ShouldBeRemoved() {
		// if a bullet, has gone far off the game window, remove it
		if(pos.y > -actualHeight) {
			return false;
		}

		return true;
	}

	void draw(Texture2D tex) {
		move();

		DrawTextureRec(tex, srect[currentFrame], pos, WHITE);
	}
}

class PaladinShip: Entity {
	private Sprite sprite;
	private double time = 0;
	private float ship_speed = 0;
	private int bullet_limit = 9;

	private Bullet[] bullet;

	private Texture2D tbullet;

	this() {
		TextureManager.getInstance().add("res/paladin.png", "paladin");
		TextureManager.getInstance().add("res/paladin_.png", "paladin_");

		sprite.tex = TextureManager.getInstance().get("paladin");
		sprite.actualWidth = sprite.actualHeight = 64;
		sprite.srect ~= Rectangle(0, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth*2, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth*3, 0, sprite.actualWidth, sprite.actualHeight);
		ship_speed = 3.6;

		tbullet = TextureManager.getInstance().get("paladin_");
	}

	~this() {}

	public void processEvents() {
		if(IsKeyDown(KeyboardKey.KEY_W) || IsKeyDown(KeyboardKey.KEY_UP)) {
			move(0, -ship_speed, EntityState.MOVING);
        } else if(IsKeyDown(KeyboardKey.KEY_S) || IsKeyDown(KeyboardKey.KEY_DOWN)) {
 			move(0, ship_speed, EntityState.STATIONARY);
        } else if(IsKeyDown(KeyboardKey.KEY_A) || IsKeyDown(KeyboardKey.KEY_LEFT)) {
        	move(-ship_speed, 0, EntityState.MOVING);
        } else if(IsKeyDown(KeyboardKey.KEY_D) || IsKeyDown(KeyboardKey.KEY_RIGHT)) {
        	move(ship_speed, 0, EntityState.MOVING);
        } else {
        	sprite.estate = EntityState.STATIONARY;
        }

        if(IsKeyPressed(KeyboardKey.KEY_SPACE)) {
        	sprite.estate = EntityState.SHOOTING;
        }
	}

	public void update() {
		// animating the ship
		time += GetFrameTime();
    	if(time > 0.15) {
    		if(sprite.estate != EntityState.STATIONARY) {
    			sprite.currentFrame++;
    			if(sprite.currentFrame > sprite.srect.length-1) {
    				sprite.currentFrame = 1;
    			}
    		} else {
    			sprite.currentFrame = 0;
    		}

    		time = 0;
    	}

		// teleport the ship from one side of the screen to another
    	if(sprite.pos.x > WIDTH) {
    		sprite.pos.x = -sprite.actualWidth;
    	} else if(sprite.pos.x+sprite.actualWidth < 0) {
    		sprite.pos.x = WIDTH;
    	} else if(sprite.pos.y+sprite.actualHeight > HEIGHT) {
			sprite.pos.y -= sprite.pos.y+sprite.actualHeight - HEIGHT;
		}

		// shooting until the bullet limit has been reached
    	if(sprite.estate == EntityState.SHOOTING && bullet.length < bullet_limit) {
    		bullet ~= Bullet(12, 32, ship_speed, 4, sprite.pos, Vector2(sprite.actualWidth, sprite.actualHeight));
    	}

		// remove the bullet
    	for(int i = 0; i < bullet.length; i++) {
    		if(bullet[i].ShouldBeRemoved()) {
				forceBulletRemove(i);
    		}
    	}
	}

	public void render() {
		for(int i = 0; i < bullet.length; i++) {
    		bullet[i].draw(tbullet);
    	}

		DrawTextureRec(sprite.tex, sprite.srect[sprite.currentFrame], sprite.pos, WHITE);
	}

	public int getActualSpriteWidth() {
		return sprite.actualWidth;
	}

	public int getActualSpriteHeight() {
		return sprite.actualHeight;
	}

	// set pos of sprite
	public void setPos(Vector2 pos) {
		sprite.pos = pos;
	}

	public void forceBulletRemove(int i) {
		bullet = bullet.remove(i);
	}

	// get pos of sprite
	public Vector2 getPos() {
		return sprite.pos;
	}

	// enforced by Entity interface
	public bool shieldOn() { return false; }

	// get a copy of rectangle(pos, size) entity
	public Rectangle getEntity(int i) {
		return Rectangle(bullet[i].pos.x, bullet[i].pos.y, bullet[i].actualWidth, bullet[i].actualHeight);
	}

	// get size of bullet array
	public ulong getEntityLength() {
		return bullet.length;
	}

	private void move(float x, float y, EntityState state) {
		sprite.pos.x += x;
		sprite.pos.y += y;

		sprite.estate = state;
	}
}

// the same as PaladinShip, but for SpecterShip
class SpecterShip: Entity {
	private Sprite sprite;
	private float ship_speed = 0;
	private int bullet_limit = 13;

	private Bullet[] bullet;

	private Texture2D tbullet;

	this() {
		TextureManager.getInstance().add("res/specter.png", "specter");
		TextureManager.getInstance().add("res/specter_.png", "specter_");

		sprite.tex = TextureManager.getInstance().get("specter");
		sprite.actualWidth = sprite.actualHeight = 64;
		sprite.srect ~= Rectangle(0, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth*2, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth*3, 0, sprite.actualWidth, sprite.actualHeight);
		ship_speed = 6;

		tbullet = TextureManager.getInstance().get("specter_");
	}

	~this() {}

	public void processEvents() {
		if(IsKeyDown(KeyboardKey.KEY_W) || IsKeyDown(KeyboardKey.KEY_UP)) {
			move(0, -ship_speed, EntityState.MOVING);
			sprite.currentFrame = 1;
        } else if(IsKeyDown(KeyboardKey.KEY_S) || IsKeyDown(KeyboardKey.KEY_DOWN)) {
 			move(0, ship_speed, EntityState.STATIONARY);
        	sprite.currentFrame = 0;
        } else if(IsKeyDown(KeyboardKey.KEY_A) || IsKeyDown(KeyboardKey.KEY_LEFT)) {
        	move(-ship_speed, 0, EntityState.MOVING);
        	sprite.currentFrame = 3;
        } else if(IsKeyDown(KeyboardKey.KEY_D) || IsKeyDown(KeyboardKey.KEY_RIGHT)) {
        	move(ship_speed, 0, EntityState.MOVING);
        	sprite.currentFrame = 2;
        } else {
        	sprite.estate = EntityState.STATIONARY;
        	sprite.currentFrame = 0;
        }

        if(IsKeyPressed(KeyboardKey.KEY_SPACE)) {
        	sprite.estate = EntityState.SHOOTING;
        }
	}

	public void update() {
		if(sprite.pos.x > WIDTH) {
    		sprite.pos.x = -sprite.actualWidth;
    	} else if(sprite.pos.x+sprite.actualWidth < 0) {
    		sprite.pos.x = WIDTH;
    	} else if(sprite.pos.y+sprite.actualHeight > HEIGHT) {
			sprite.pos.y -= sprite.pos.y+sprite.actualHeight - HEIGHT;
		}

    	if(sprite.estate == EntityState.SHOOTING && bullet.length < bullet_limit) {
    		bullet ~= Bullet(12, 32, ship_speed, 4, sprite.pos, Vector2(sprite.actualWidth, sprite.actualHeight));
    	}

    	for(int i = 0; i < bullet.length; i++) {
    		if(bullet[i].ShouldBeRemoved()) {
    			forceBulletRemove(i);
    		}
    	}
	}

	public void render() {
		for(int i = 0; i < bullet.length; i++) {
    		bullet[i].draw(tbullet);
    	}

		DrawTextureRec(sprite.tex, sprite.srect[sprite.currentFrame], sprite.pos, WHITE);
	}

	public int getActualSpriteWidth() {
		return sprite.actualWidth;
	}

	public int getActualSpriteHeight() {
		return sprite.actualHeight;
	}

	public void setPos(Vector2 pos) {
		sprite.pos = pos;
	}

	public void forceBulletRemove(int i) {
		bullet = bullet.remove(i);
	}

	public Vector2 getPos() {
		return sprite.pos;
	}

	public bool shieldOn() { return false; }

	public Rectangle getEntity(int i) {
		return Rectangle(bullet[i].pos.x, bullet[i].pos.y, bullet[i].actualWidth, bullet[i].actualHeight);
	}

	public ulong getEntityLength() {
		return bullet.length;
	}

	private void move(float x, float y, EntityState state) {
		sprite.pos.x += x;
		sprite.pos.y += y;

		sprite.estate = state;
	}
}

// the same as PaladinShip, but for SpecterShip
class StarhammerShip: Entity {
	private Sprite sprite;
	private double time = 0;
	private float ship_speed = 0;
	private int bullet_limit = 7;

	private Bullet[] bullet;

	private Texture2D tbullet;

	private bool shield_on = false;

	this() {
		TextureManager.getInstance().add("res/starhammer.png", "starhammer");
		TextureManager.getInstance().add("res/starhammer_.png", "starhammer_");

		sprite.tex = TextureManager.getInstance().get("starhammer");
		sprite.actualWidth = 128;
		sprite.actualHeight = 64;
		sprite.srect ~= Rectangle(0, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth*2, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth*3, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth*4, 0, sprite.actualWidth, sprite.actualHeight);
		ship_speed = 2.1;

		tbullet = TextureManager.getInstance().get("starhammer_");
	}

	~this() {}

	public void processEvents() {
		if(IsKeyDown(KeyboardKey.KEY_W) || IsKeyDown(KeyboardKey.KEY_UP)) {
			move(0, -ship_speed, EntityState.MOVING);
        } else if(IsKeyDown(KeyboardKey.KEY_S) || IsKeyDown(KeyboardKey.KEY_DOWN)) {
 			move(0, ship_speed, EntityState.STATIONARY);
        } else if(IsKeyDown(KeyboardKey.KEY_A) || IsKeyDown(KeyboardKey.KEY_LEFT)) {
        	move(-ship_speed, 0, EntityState.MOVING);
        } else if(IsKeyDown(KeyboardKey.KEY_D) || IsKeyDown(KeyboardKey.KEY_RIGHT)) {
        	move(ship_speed, 0, EntityState.MOVING);
        } else if(IsKeyDown(KeyboardKey.KEY_F)) {
			sprite.currentFrame = to!int(sprite.srect.length-1);
			shield_on = true;
        } else {
        	sprite.estate = EntityState.STATIONARY;
        }

        if(IsKeyPressed(KeyboardKey.KEY_SPACE)) {
        	sprite.estate = EntityState.SHOOTING;
        }
	}

	public void update() {
		time += GetFrameTime();
    	if(time > 0.15 && sprite.estate != EntityState.SHOOTING) {
    		if(sprite.estate != EntityState.STATIONARY) {
    			sprite.currentFrame++;
    			if(sprite.currentFrame > sprite.srect.length-2) {
    				sprite.currentFrame = 1;
    			}
    		} else {
    			sprite.currentFrame = 0;
				shield_on = false;
    		}

    		time = 0;
    	}

    	if(sprite.pos.x > WIDTH) {
    		sprite.pos.x = -sprite.actualWidth;
    	} else if(sprite.pos.x+sprite.actualWidth < 0) {
    		sprite.pos.x = WIDTH;
    	} else if(sprite.pos.y+sprite.actualHeight > HEIGHT) {
			sprite.pos.y -= sprite.pos.y+sprite.actualHeight - HEIGHT;
		}

    	if(sprite.estate == EntityState.SHOOTING && bullet.length < bullet_limit) {
    		bullet ~= Bullet(27, 128, ship_speed, 4, sprite.pos, Vector2(sprite.actualWidth, -sprite.actualHeight));
    	}

    	for(int i = 0; i < bullet.length; i++) {
    		if(bullet[i].ShouldBeRemoved()) {
    			forceBulletRemove(i);
    		}
    	}
	}

	public void render() {
		DrawTextureRec(sprite.tex, sprite.srect[sprite.currentFrame], sprite.pos, WHITE);

		for(int i = 0; i < bullet.length; i++) {
    		bullet[i].draw(tbullet);
    	}
	}

	public int getActualSpriteWidth() {
		return sprite.actualWidth;
	}

	public int getActualSpriteHeight() {
		return sprite.actualHeight;
	}

	public void setPos(Vector2 pos) {
		sprite.pos = pos;
	}

	public void forceBulletRemove(int i) {
		bullet = bullet.remove(i);
	}

	public Vector2 getPos() {
		return sprite.pos;
	}

	public bool shieldOn() {
		return shield_on;
	}

	public Rectangle getEntity(int i) {
		return Rectangle(bullet[i].pos.x, bullet[i].pos.y, bullet[i].actualWidth, bullet[i].actualHeight);
	}

	public ulong getEntityLength() {
		return bullet.length;
	}

	private void move(float x, float y, EntityState state) {
		sprite.pos.x += x;
		sprite.pos.y += y;

		sprite.estate = state;
	}
}
