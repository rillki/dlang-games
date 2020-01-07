import std.stdio: writeln;
import std.conv: to;
import std.random: uniform;

import raylib;

void main() {
    immutable int WIDTH = 640;
    immutable int HEIGHT = 480;
    immutable int BLOCK_SIZE = 16;

    // init
    InitWindow(WIDTH, HEIGHT, "Dlang Tron");
    SetTargetFPS(30);

    Texture2D tsprite = LoadTexture("res/sprite.png");
    Rectangle[6] srect;
    for(int i = 0; i < srect.length; i++) {
        srect[i].width = srect[i].height = BLOCK_SIZE;
        srect[i].x = BLOCK_SIZE*i;
        srect[i].y = 0;
    }

    // randomizing player position
    int player1 = uniform(0, 6);
    int player2 = uniform(0, 6);
    while(player1 == player2) {
    	player2 = uniform(0, 6);
    }

    // game board
    int[WIDTH/BLOCK_SIZE][HEIGHT/BLOCK_SIZE] grid = 0;
    Vector2 player1Pos = Vector2(uniform(0, grid[0].length)*BLOCK_SIZE, uniform(0, grid.length)*BLOCK_SIZE);
    Vector2 player2Pos = Vector2(uniform(0, grid[0].length)*BLOCK_SIZE, uniform(0, grid.length)*BLOCK_SIZE);
    
    bool gameOver = false;
    while(!WindowShouldClose()) {
        // process events
        if(!gameOver) {
            player1Pos.x /= BLOCK_SIZE;
            player1Pos.y /= BLOCK_SIZE;

            player2Pos.x /= BLOCK_SIZE;
            player2Pos.y /= BLOCK_SIZE;

            if(IsKeyDown(KeyboardKey.KEY_A) || IsKeyDown(KeyboardKey.KEY_LEFT)) {
                player1Pos.x--;
                player2Pos.x++;
            } else if(IsKeyDown(KeyboardKey.KEY_D) || IsKeyDown(KeyboardKey.KEY_RIGHT)) {
                player1Pos.x++;
                player2Pos.x--;
            } else if(IsKeyDown(KeyboardKey.KEY_W) || IsKeyDown(KeyboardKey.KEY_UP)) {
                player1Pos.y--;
                player2Pos.y--;
            } else if(IsKeyDown(KeyboardKey.KEY_S) || IsKeyDown(KeyboardKey.KEY_DOWN)) {
                player1Pos.y++;
                player2Pos.y++;
            }

            // update
            // check if player1 is within the bounds of the game board
            if(player1Pos.x < 0) {
                player1Pos.x = grid[0].length - 1;
            } else if(player1Pos.x > grid[0].length-1) {
                player1Pos.x = 0;
            } else if(player1Pos.y < 0) {
                player1Pos.y = grid.length - 1;
            } else if(player1Pos.y > grid.length-1) {
                player1Pos.y = 0;
            }

            // check if player2 is within the bounds of the game board
            if(player2Pos.x < 0) {
                player2Pos.x = grid[0].length - 1;
            } else if(player2Pos.x > grid[0].length-1) {
                player2Pos.x = 0;
            } else if(player2Pos.y < 0) {
                player2Pos.y = grid.length - 1;
            } else if(player2Pos.y > grid.length-1) {
                player2Pos.y = 0;
            }

            int x1 = player1Pos.x.to!int;
            int y1 = player1Pos.y.to!int;
            int x2 = player2Pos.x.to!int;
            int y2 = player2Pos.y.to!int;

            // if player1 hit player 2 and/or vice versa -> game over
            if(grid[y1][x1] == 2 || grid[y2][x2] == 1) {
                gameOver = true;
            } else {
            	// otherwise update player1 and player2 position on the board
                grid[y1][x1] = 1;
                grid[y2][x2] = 2;

                player1Pos.x *= BLOCK_SIZE;
                player1Pos.y *= BLOCK_SIZE;

                player2Pos.x *= BLOCK_SIZE;
                player2Pos.y *= BLOCK_SIZE;
            }
        }

        // draw
        BeginDrawing();
        ClearBackground(WHITE);

        for(int i = 0; i < grid.length; i++) {
            for(int j = 0; j < grid[0].length; j++) {
                if(grid[i][j] == 1) {
                    Vector2 pos = Vector2(j*BLOCK_SIZE, i*BLOCK_SIZE);
                    DrawTextureRec(tsprite, srect[player1], pos, WHITE);
                } else if(grid[i][j] == 2) {
                    Vector2 pos = Vector2(j*BLOCK_SIZE, i*BLOCK_SIZE);
                    DrawTextureRec(tsprite, srect[player2], pos, WHITE);
                }
            }
        }

        if(gameOver) {
            DrawText("Game Over!", WIDTH/6, HEIGHT/3, 81, Color(100, 100, 100, 150));
        }

        EndDrawing();
    }

    UnloadTexture(tsprite);
    CloseWindow();
}
