module play;

import raylib;
import std.random: uniform;
import std.conv: to;
import std.string: toStringz;

import data;
import starship;
import enemy;
import resmanager;

GameState execute(Play play) {
	while(play.gstate == GameState.PLAY) {
		play.processEvents();
		play.update();
		play.render();
	}

	return play.gstate;
}

class Play {
    GameState gstate;
    StarshipType shipType;
    EnemySystem enemySystem;

    Sprite shp;

    Texture2D tbackground;
    Texture2D thp;

    Entity pship;

    bool gameOver = false;
    double time = 0;

	int score = 0;
	int shp_speed = 1;
	float lives = 12;
	float shp_rotation = 0;

	this(GameState gstate, StarshipType shipType) {
		this.gstate = gstate;
		this.shipType = shipType;

		if(shipType == StarshipType.SPECTER) {
			lives = 9;
		} else if(shipType == StarshipType.STARHAMMER) {
			lives = 16;
		}

		int num = uniform(0, 6);
		switch(num) {
			case 0:
				tbackground = ResManager!Texture2D.getInstance.get("play1");
				break;
			case 1:
				tbackground = ResManager!Texture2D.getInstance.get("play2");
				break;
			case 2:
				tbackground = ResManager!Texture2D.getInstance.get("play3");
				break;
			case 3:
				tbackground = ResManager!Texture2D.getInstance.get("play4");
				break;
			case 4:
				tbackground = ResManager!Texture2D.getInstance.get("play5");
				break;
			default:
				tbackground = ResManager!Texture2D.getInstance.get("play6");
				break;
		}
		tbackground.width = WIDTH;
		tbackground.height = HEIGHT;

		shp.tex = ResManager!Texture2D.getInstance.get("hp");
		shp.pos = Vector2(uniform(0, WIDTH-shp.tex.width), -shp.tex.height);
		shp.estate = EntityState.MOVING;

		thp = ResManager!Texture2D.getInstance.get("hp");

		if(shipType == StarshipType.PALADIN) {
			pship = new PaladinShip();
		} else if(shipType == StarshipType.SPECTER) {
			pship = new SpecterShip();
		} else {
			pship = new StarhammerShip();
		}
		pship.setPos(Vector2(WIDTH/2 - pship.getActualSpriteWidth/2, HEIGHT*3/4));

		enemySystem = new EnemySystem();
	}

	~this() {}

	private void processEvents() {
        if(WindowShouldClose()) {
        	gstate = GameState.EXIT;
        } else if(IsKeyPressed(KeyboardKey.KEY_BACKSPACE)) {
        	gstate = GameState.MENU;
        }

        if(!gameOver) {
			pship.processEvents();
       		enemySystem.processEvents();
        }
    }

    private void update() {
    	if(!gameOver) {
    		pship.update();
	        enemySystem.update();

			// collision between the enemy ship and a bullet
	        for(int i = 0; i < pship.getEntityLength(); i++) {
	        	for(int j = 0; j < enemySystem.getEntityLength(); j++) {
	        		if(CheckCollisionRecs(pship.getEntity(i), enemySystem.getEntity(j)) && enemySystem.getEntityState(j) != EntityState.EXPLODING) {
	        			enemySystem.setEntityState(j, EntityState.EXPLODING);
						if(shipType != StarshipType.STARHAMMER) {
							pship.forceBulletRemove(i);
						}

	        			score++;
	        			goto cont;
	        		}
	        	}
	        }

			// collision between the enemy ship and player
	        for(int j = 0; j < enemySystem.getEntityLength(); j++) {
	    		if(CheckCollisionRecs(Rectangle(pship.getPos().x, pship.getPos().y, pship.getActualSpriteWidth(), pship.getActualSpriteHeight()), enemySystem.getEntity(j))
	    		 && enemySystem.getEntityState(j) != EntityState.EXPLODING) {
	    			enemySystem.setEntityState(j, EntityState.EXPLODING);

					if(shipType == StarshipType.STARHAMMER && pship.shieldOn()) {
						lives -= 0.5;
					} else {
						lives--;

					}

	    			goto cont;
	    		}
	        }
	        cont:

			if(shp.estate != EntityState.DESTROYED) {
				shp.pos.y += shp_speed;

				if(CheckCollisionRecs(Rectangle(pship.getPos().x, pship.getPos().y, pship.getActualSpriteWidth(), pship.getActualSpriteHeight()),
				Rectangle(shp.pos.x, shp.pos.y, shp.tex.width, shp.tex.height))) {
					lives++;
					shp.estate = EntityState.DESTROYED;
				}
			}

			if(shp.pos.y > HEIGHT || shp.estate == EntityState.DESTROYED) {
				shp.pos.y = -uniform(0, HEIGHT);
				shp.pos.x = uniform(0, WIDTH-shp.tex.width);
				shp_rotation = uniform(0, 360);

				shp.estate = EntityState.MOVING;
			}

			shp_rotation++;

	        if(lives < 0) {
	        	gameOver = true;
	        }
    	}
    }

    private void render() {
		BeginDrawing();
		ClearBackground(BLACK);
		DrawTexture(tbackground, 0, 0, WHITE);
		DrawFPS(WIDTH/2-40, 10);

		if(shp.estate != EntityState.DESTROYED) {
			DrawTextureEx(shp.tex, shp.pos, shp_rotation, 1.0, WHITE);
		}

		pship.render();
        enemySystem.render();

		DrawTexture(thp, 5, 20, WHITE);
        DrawText(toStringz(lives.to!string), 45, 10, 60, WHITE);
        DrawText(toStringz(score.to!string), 5, 70, 30, WHITE);

        if(gameOver) {
        	DrawRectangleRec(Rectangle(0, 0, tbackground.width, tbackground.height), Color(0, 0, 0, 180));
        	DrawText("Game Over!", (tbackground.width/3.4).to!int, (tbackground.height/3.2).to!int, 81, WHITE);
			DrawText(toStringz("Score: " ~ to!string(score)), (tbackground.width/3.4).to!int, (tbackground.height/5*3).to!int, 81, WHITE);
        }

		EndDrawing();
    }
}
