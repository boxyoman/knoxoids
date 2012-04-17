//
//  game.h
//  knoxoids
//
//  Created by Jonathan Covert on 4/5/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#ifndef knoxoids_game_h
#define knoxoids_game_h

#import <Accelerate/Accelerate.h>

typedef enum {
    background,
    survival
}gametype;

enum{
    x = 0,
    y = 1
};

typedef struct asteroids20{
    float p[2][20] __attribute__ ((aligned));
    float pp[2][20] __attribute__ ((aligned));
    float v[2][20] __attribute__ ((aligned));
    float m[20] __attribute__ ((aligned));
    struct asteroids10 *next;
}asteroids20;

typedef struct{
    float p[2];
    float pp[2];
    float v[2];
    float f[2];
    float m;
    int gunOn;
    float ang;
    int show;
    int sheild;
}you;

typedef struct{
    float p[2];
    float pp[2];
    float v[2];
    float m;
}mFood;

typedef struct food30{
    float p[2][30] __attribute__ ((aligned));
    float pp[2][30] __attribute__ ((aligned));
    float v[2][30] __attribute__ ((aligned));
    float m[30] __attribute__ ((aligned));
    struct food30 *next;
}food30;

typedef struct ships5{
    float p[2][5] __attribute__ ((aligned));
    float pp[2][5] __attribute__ ((aligned));
    float v[2][5] __attribute__ ((aligned));
    float f[2][5] __attribute__ ((aligned));
    float m[5] __attribute__ ((aligned));
    int gunOn[5] __attribute__ ((aligned));
    float ang[5] __attribute__ ((aligned));
    int show[5] __attribute__ ((aligned));
    int sheild[5] __attribute__ ((aligned));
    struct ships5 *next;
}ships5;

typedef struct{
    float *x;
    float *y;
}vector2;

typedef struct{
    int width;
    int height;
    float crad;
    gametype gt;
    you you;
    
    mFood *mFood;
    
    asteroids20 *asteroids;
    food30 *bullet;
    
    food30 *food;
    ships5 *ships;
}game;



game* makeNewGame(int width, int height, float crad, gametype gt);
void changeGameTypeTo(game *g, gametype gt);

void update(game *g, float h);
void updateYouMfood(game *g, float h);
void updateBullets(game *g, float h);
void updateAteroids(game *g, float h);
void updateFood(game *g, float h);

void shoot(game *g, float *p, float *v, float *m, float *ang, int *gunOn);
void shotAsteroid(game *g, asteroids20 *ast, int ia, food30 *bullet, int ib);

void makeBullet(game *g, float *p, float *v);
void makeFood(game *g, float *p, float *v);
void removeBullet(food30 *bullets, int i);
void removeAsteroid(asteroids20 *ast, int i);

int wall(game *g, float *p, float *v, int m);
int collide(game *g, float *p1, float *pp1, float *v1, int m1, float *p2, float *pp2, float *v2, int m2, float h);


float size(const game* g, int mass);
#endif
