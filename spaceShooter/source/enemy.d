module enemy;

import raylib;
import std.random: uniform;

import data;
import texturemanager;

class EnemySystem {
	private Enemy[] e;			// enemies

	private double time = 0;	// for adding new enemies every few seconds

	this() {
		TextureManager.getInstance().add("res/enemy1.png", "enemy1");
		TextureManager.getInstance().add("res/enemy2.png", "enemy2");

		// adding different enemies
		for(int i = 0; i < 9; i++) {
			int rand = uniform(0, 4);
			if(rand) {
				e ~= new Enemy(TextureManager.getInstance().get("enemy1"), 0.81, 48);
			} else {
				e ~= new Enemy(TextureManager.getInstance().get("enemy2"), 1.91, 32);
			}
			e[i].setPos(Vector2(uniform(0, WIDTH), -uniform(0, HEIGHT)));
		}
	}

	public void processEvents() {
		for(int i = 0; i < e.length; i++) {
			e[i].processEvents();
		}
	}

	public void update() {
		for(int i = 0; i < e.length; i++) {
			e[i].update();

			// if entity was destroyed, respawn it
			if(e[i].getEntityState() == EntityState.DESTROYED) {
				e[i].setEntityState(EntityState.MOVING);
				e[i].setPos(Vector2(uniform(0, WIDTH), -uniform(0, HEIGHT)));
			}
		}

		// adding new enemies
		time += GetFrameTime();
		if(time > 4.5 && e.length < 120) {
			int rand = uniform(0, 4);
			if(rand) {
				e ~= new Enemy(TextureManager.getInstance().get("enemy1"), 0.81, 48);
			} else {
				e ~= new Enemy(TextureManager.getInstance().get("enemy2"), 1.91, 32);
			}
			e[e.length-1].setPos(Vector2(uniform(0, WIDTH), -uniform(0, HEIGHT)));

			time = 0;
		}
	}

	public void render() {
		for(int i = 0; i < e.length; i++) {
			e[i].render();
		}
	}

	public ulong getEntityLength() {
		return e.length;
	}

	// getting a copy of a rectangle(pos, size) entity
	public Rectangle getEntity(int i) {
		return Rectangle(e[i].getPos().x, e[i].getPos().y, e[i].getActualSpriteWidth(), e[i].getActualSpriteHeight());
	}

	public void setEntityState(int i, EntityState state) {
		e[i].setEntityState(state);
	}

	public EntityState getEntityState(int i) {
		return e[i].getEntityState();
	}
}

class Enemy: Entity {
	Sprite sprite;			// enemy ship sprite
	Sprite sexplosion;		// explosion sprite

	double time = 0;		// for animation
	float e_speed = 0;		// speed of the enemy

	this(Texture2D t, float speed, int size) {
		sprite.tex = t;
		sprite.actualWidth = sprite.actualHeight = size;
		sprite.srect ~= Rectangle(0, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth, 0, sprite.actualWidth, sprite.actualHeight);
		sprite.srect ~= Rectangle(sprite.actualWidth*2, 0, sprite.actualWidth, sprite.actualHeight);
		e_speed = speed;

		TextureManager.getInstance().add("res/exp32.png", "exp32");
		TextureManager.getInstance().add("res/exp48.png", "exp48");

		if(size == 32) {
			sexplosion.tex = TextureManager.getInstance().get("exp32");
		} else {
			sexplosion.tex = TextureManager.getInstance().get("exp48");
		}
		sexplosion.actualWidth = sexplosion.actualHeight = size;
		for(int i = 0; i < 9; i++) {
			sexplosion.srect ~= Rectangle(sprite.actualWidth*i, 0, sprite.actualWidth, sprite.actualHeight);
		}
	}

	public void processEvents() {}

	public void update() {
		time += GetFrameTime();

		if(sprite.pos.y > HEIGHT) {
			sprite.pos = Vector2(uniform(0, WIDTH), -uniform(0, HEIGHT));
		}

		// animating the enemy ship
		if(sprite.estate != EntityState.EXPLODING && sprite.estate != EntityState.DESTROYED) {
			if(time > 0.13) {
				sprite.currentFrame++;
				if(sprite.currentFrame > sprite.srect.length-1) {
					sprite.currentFrame = 0;
				}

				time = 0;
			}

			move(0, e_speed, EntityState.MOVING);
		} else if(sprite.estate == EntityState.EXPLODING) { // animating explosion when the enemy ship is destroyed
			if(time > 0.1) {
				sexplosion.currentFrame++;
				if(sexplosion.currentFrame > sexplosion.srect.length-1) {
					sexplosion.currentFrame = 0;
					sprite.estate = EntityState.DESTROYED;
				}

				time = 0;
			}
		}
	}

	public void render() {
		if(sprite.estate != EntityState.EXPLODING && sprite.estate != EntityState.DESTROYED) {
			DrawTextureRec(sprite.tex, sprite.srect[sprite.currentFrame], sprite.pos, WHITE);
		} else if(sprite.estate == EntityState.EXPLODING) {
			DrawTextureRec(sexplosion.tex, sexplosion.srect[sexplosion.currentFrame], sprite.pos, WHITE);
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

	public void forceBulletRemove(int i) {}								 	// enforced by the Entity interface

	public void setEntityState(EntityState state) {
		sprite.estate = state;
	}

	public EntityState getEntityState() {
		return sprite.estate;
	}

	public Vector2 getPos() {
		return sprite.pos;
	}

	public bool shieldOn() { return false; }								// enforced by the Entity interface

	public Rectangle getEntity(int i) { return Rectangle(0, 0, 0, 0); }		// enforced by the Entity interface

	public ulong getEntityLength() { return 0; }							// enforced by the Entity interface

	private void move(float x, float y, EntityState state) {
		sprite.pos.x += x;
		sprite.pos.y += y;
		sprite.estate = state;
	}
}
