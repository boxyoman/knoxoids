//
//  game.c
//  knoxoids
//
//  Created by Jonathan Covert on 4/5/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include "math.h"
#include "game.h"

#define pi 3.1415926536
#define sd 8

game* makeNewGame(int width, int height, float crad, gametype gt){
    game *g = malloc(sizeof(game));
    
    g->width = width;
    g->height = height;
    g->crad = crad;
    g->gt = gt;
    //Setting up you
    
    g->you.p[x] = width/2;
    g->you.p[y] = height/2;
    g->you.pp[x] = width/2;
    g->you.pp[y] = height/2;
    g->you.v[x] = 0;
    g->you.v[y] = 0;
    g->you.f[x] = 0;
    g->you.f[y] = 0;
    g->you.m = 5;
    g->you.show = 1;
    g->you.gunOn = 1;
    g->you.ang = 0;
    
    
    g->mFood = malloc(sizeof(mFood));
    g->mFood->p[x] = 24*g->crad;
    g->mFood->p[y] = 25*g->crad;
    g->mFood->pp[x] = 24*g->crad;
    g->mFood->pp[y] = 25*g->crad;
    g->mFood->v[x] = 0;
    g->mFood->v[y] = 0;
    
    g->mFood->m = 0;
    
    //set up the bullets
    g->bullet = malloc(sizeof(food30));
    for (int i = 0; i<30; i++) {
        g->bullet->p[x][i] = 0;
        g->bullet->p[y][i] = 0;
        g->bullet->pp[x][i] = 0;
        g->bullet->pp[y][i] = 0;
        g->bullet->v[x][i] = 0;
        g->bullet->v[y][i] = 0;
        g->bullet->m[i] = 1;
    }
    
    g->food = malloc(sizeof(food30));
    for (int i = 0; i<30; i++) {
        g->food->p[x][i] = 0;
        g->food->p[y][i] = 0;
        g->food->pp[x][i] = 0;
        g->food->pp[y][i] = 0;
        g->food->v[x][i] = 0;
        g->food->v[y][i] = 0;
        g->food->m[i] = 0;
    }
    
    g->asteroids = malloc(sizeof(asteroids20));
    for (int i = 0; i<20; i++) {
        g->asteroids->p[x][i] = 0;
        g->asteroids->p[y][i] = 0;
        g->asteroids->pp[x][i] = 0;
        g->asteroids->pp[y][i] = 0;
        g->asteroids->v[x][i] = 0;
        g->asteroids->v[y][i] = 0;
        g->asteroids->m[i] = 0;
    }
    g->asteroids->p[x][1] = 200;
    g->asteroids->p[y][1] = 220;
    g->asteroids->pp[x][1] = 10;
    g->asteroids->pp[y][1] = 30;
    g->asteroids->v[x][1] = -30;
    g->asteroids->v[y][1] = -30;
    g->asteroids->m[1] = 5;
    
    
    g->asteroids->p[x][0] = 100;
    g->asteroids->p[y][0] = 120;
    g->asteroids->pp[x][0] = 100;
    g->asteroids->pp[y][0] = 120;
    g->asteroids->v[x][0] = 30;
    g->asteroids->v[y][0] = 30;
    g->asteroids->m[0] = 5;

    return g;
}

void shoot(game *g, float *p, float *v, float *m, float *ang, int *gunOn){
    
    if (*m >= 3 && *gunOn) {
        float p1[2];
        
        p1[x] = cos(*ang)*(size(g, *m)+size(g, 1)+g->crad)+p[x];
        p1[y] = sin(*ang)*(size(g, *m)+size(g, 1)+g->crad)+p[y];
        if (*m == 3) {
            *gunOn = 0;
        }else{
            *m -= 1;
        }
        
        float v1[2];
        v1[x] = cos(*ang)*110*g->crad;
        v1[y] = sin(*ang)*110*g->crad;
        
        v[x] = ((*m+1)*(v[x])-v1[x])/(*m);
        v[y] = ((*m+1)*(v[y])-v1[y])/(*m);
        
        makeBullet(g, p1, v1);
    }
}

void shotAsteroid(game *g, asteroids20 *ast, int ia, food30 *bullet, int ib){
    float engeryReleased = 10000;
    //if (ast->m[ia]<=5) {
        float vel = sqrt(2*engeryReleased/ast->m[ia]);
        for(double counter = 0; counter<2*pi; counter=counter+2*pi/ast->m[ia]) {
            float s = size(g, ast->m[ia]);
            
            float vn[2];
            float pn[2];
            pn[x] = ast->p[x][ia]+(s-g->crad+2)*sin(counter);
            pn[y] = ast->p[y][ia]+(s-g->crad+2)*cos(counter);
            
            float distx = bullet->p[x][ib] - pn[x];
            float disty = bullet->p[y][ib] - pn[y];
            
            vn[x] = sin(counter)*vel+ast->v[x][ia]*30/(distx*distx+5);
            vn[y] = cos(counter)*vel+ast->v[y][ia]*30/(disty*disty+5);
            
            makeFood(g, pn, vn);
        }
        removeBullet(bullet, ib);
        removeAsteroid(ast, ia);
    //}else {
    //    removeBullet(bullet, ib);
    //}
}
void makeFood(game *g, float *p, float *v){
    int i = 0;
    for (; g->food->p[x][i] != 0 && i<30; i++) {}
    
    g->food->p[x][i] = p[x];
    g->food->p[y][i] = p[y];
    g->food->pp[x][i] = p[x];
    g->food->pp[y][i] = p[y];
    g->food->m[i] = 1;
    
    if(v==NULL){
        g->food->v[x][i] = 0;
        g->food->v[y][i] = 0;
    }else {
        g->food->v[x][i] = v[x];
        g->food->v[y][i] = v[y];
    }
}
void makeAstroid(game *g, float *p, float *v, float m){
    
    
    
}
void makeBullet(game *g, float *p, float *v){
    int i = 0;
    for (; g->bullet->p[x][i] != 0 && i<30; i++) {}
    
    g->bullet->p[x][i] = p[x];
    g->bullet->p[y][i] = p[y];
    g->bullet->pp[x][i] = p[x];
    g->bullet->pp[y][i] = p[y];
    g->bullet->m[i] = 1;

    if(v==NULL){
        g->bullet->v[x][i] = 0;
        g->bullet->v[y][i] = 0;
    }else {
        g->bullet->v[x][i] = v[x];
        g->bullet->v[y][i] = v[y];
    }
}
void removeAsteroid(asteroids20 *ast, int i){
    ast->p[x][i] = 0;
    ast->p[y][i] = 0;
    ast->pp[x][i] = 0;
    ast->pp[y][i] = 0;
    ast->v[x][i] = 0;
    ast->v[y][i] = 0;
}
void removeBullet(food30 *bullets, int i){
    bullets->p[x][i] = 0;
    bullets->p[y][i] = 0;
    bullets->pp[x][i] = 0;
    bullets->pp[y][i] = 0;
    bullets->v[x][i] = 0;
    bullets->v[y][i] = 0;
}

void changeGameTypeTo(game *g, gametype gt){
    g->gt = gt;
    
}

float size(const game* g, int mass) {
	if(mass <=1){
		return mass*g->crad;
	}
	else{
		return g->crad/(cos(pi*(mass-2)/(2*mass)))+g->crad;
	}
}

int wall(game *g, float *p, float *v, int m){
    float s = size(g, m);
    if (p[x] > g->width-s) {
        p[x] = g->width-s;
        v[x] *= -1;
        return 1;
    }
    if(p[x]-s<0){
        p[x] = s;
        v[x] *= -1;
        return 1;
    }
    if (p[y] > g->height-s) {
        p[y] = g->height-s;
        v[y] *= -1;
        return 1;
    }
    if (p[y]-s<0) {
        p[y] = s;
        v[y] *= -1;
        return 1;
    }
    return 0;
}
double abss(double num){
    if (num<0) {
        num *= -1;
    }
    return num;
}
int sign(double num){
    if (num<0) {
        return -1;
    }else{
        return 1;
    }
}
int collide(game *g, float p1[], float pp1[], float v1[], int m1, float p2[], float pp2[], float v2[], int m2, float h){
    
    float addSize = size(g, m2)+size(g, m1);
    float dx1[sd]__attribute__ ((aligned));
    float dy1[sd]__attribute__ ((aligned));
    float dx2[sd]__attribute__ ((aligned));
    float dy2[sd]__attribute__ ((aligned));
    
    float dx[sd]__attribute__ ((aligned));
    float dy[sd]__attribute__ ((aligned));
    float dd[sd]__attribute__ ((aligned));
    
    vDSP_vgen(&pp1[x], &p1[x], dx1, 1, sd);
    vDSP_vgen(&pp1[y], &p1[y], dy1, 1, sd);    
    vDSP_vgen(&pp2[x], &p2[x], dx2, 1, sd);
    vDSP_vgen(&pp2[y], &p2[y], dy2, 1, sd); 
    
    vDSP_vsub(dx1, 1, dx2, 1, dx, 1, sd);
    vDSP_vsub(dy1, 1, dy2, 1, dy, 1, sd);
    
    vDSP_vdist(dx, 1, dy, 1, dd, 1, sd);
    
    for (int i=0; i<sd; i++) {
        if (dd[i] < addSize) {
            float ang1 = atan2(dy[i], dx[i]);
            float ang2 = atan2(-dy[i], -dx[i]);
            
            p2[x] = dx2[i]+((addSize-dd[i])/2+1)*cos(ang1);
            p2[y] = dy2[i]+((addSize-dd[i])/2+1)*sin(ang1);
            pp2[x] = p2[x];
            pp2[y] = p2[y];
            
            p1[x] = dx1[i]+((addSize-dd[i])/2+1)*cos(ang2);
            p1[y] = dy1[i]+((addSize-dd[i])/2+1)*sin(ang2);
            pp1[x] = p1[x];
            pp1[y] = p1[y];
            
            
            float vx1 = cos(ang1)*v1[x] + cos(pi/2+ang1)*v1[y];
            float vy1 = sin(ang1)*v1[x] + sin(pi/2+ang1)*v1[y];
            float vx2 = cos(ang2)*v2[x] + cos(pi/2+ang2)*v2[y];
            float vy2 = sin(ang2)*v2[x] + sin(pi/2+ang2)*v2[y];
            
            float vyf1 = ((m1 - m2)*vy1 + 2*m2*vy2)/(m1+m2);
            float vyf2 = ((m2 - m1)*vy2 + 2*m1*vy1)/(m1+m2);
            
            v1[x] = sin(-ang1)*vx1 + sin(-(pi/2+ang1))*vyf1;
            v2[x] = sin(-ang2)*vx2 + sin(-(pi/2+ang2))*vyf2;
            
            v1[y] = cos(-ang1)*vx1 + cos(-(pi/2+ang1))*vyf1;
            v2[y] = cos(-ang2)*vx2 + cos(-(pi/2+ang2))*vyf2;
            
            return 1;
        }
    }
    return 0;
}
void update(game *g, float h){
    if (h>.04) {
        h=.04;
    }
    if(g != NULL && h != 0){
        //You
        updateYouMfood(g, h);
        
        //Bullets
        updateBullets(g, h);
        
        //Asteroids
        updateAteroids(g, h);
        
        //Food
        updateFood(g, h);
    }
}
void updateYouMfood(game *g, float h){
    g->you.pp[x] = g->you.p[x];
    g->you.pp[y] = g->you.p[y];
    
    float s = size(g, g->you.m);
    //v = -0.01 * velocity * area * ∆t/mass + force/mass * ∆t
    g->you.v[x] += -.04/g->crad*g->you.v[x]*s*s*pi*h/g->you.m + g->you.f[x]/g->you.m*h;
    g->you.v[y] += -.04/g->crad*g->you.v[y]*s*s*pi*h/g->you.m + g->you.f[y]/g->you.m*h;
    //p = v * t
    g->you.p[x] += g->you.v[x]*h;
    g->you.p[y] += g->you.v[y]*h;
    if (g->you.m < 5) {
        g->you.m++;
    }
    g->you.gunOn = 1;
    //g->you.ang = pi;
    if (wall(g, g->you.p, g->you.v, g->you.m)) {
        g->you.gunOn = 0;
    }
    if (collide(g, g->you.p, g->you.pp, g->you.v, g->you.m, g->mFood->p, g->mFood->pp, g->mFood->v, 1, h)) {
        g->you.m ++;
        g->mFood->p[x] = 3;
        g->mFood->p[y] = 30;
        g->mFood->v[x] = 0;
        g->mFood->v[y] = 0;
    }
    g->mFood->pp[x] = g->mFood->p[x];
    g->mFood->pp[y] = g->mFood->p[y];
    g->mFood->v[x] += -4/g->crad*g->mFood->v[x]*pi*h;
    g->mFood->v[y] += -4/g->crad*g->mFood->v[y]*pi*h;
    
    //p = v * t
    g->mFood->p[x] += g->mFood->v[x]*h;
    g->mFood->p[y] += g->mFood->v[y]*h;
    wall(g, g->mFood->p, g->mFood->v, 1);
}

void updateBullets(game *g, float h){
    vDSP_mmov(g->bullet->p, g->bullet->pp, 30, 2, 30, 30);
    //p = v*∆t + p
    vDSP_vsma(g->bullet->v[x], 1, &h, g->bullet->p[x], 1, g->bullet->p[x], 1, 30);
    vDSP_vsma(g->bullet->v[y], 1, &h, g->bullet->p[y], 1, g->bullet->p[y], 1, 30);
    int stopLoop = 0;
    for(int i=0; i<30; i++){
        stopLoop = 0;
        if(g->bullet->p[x][i] != 0){
            //p = v * t
            
            float p[2] = {g->bullet->p[x][i], g->bullet->p[y][i]};
            float v[2] = {g->bullet->v[x][i], g->bullet->v[y][i]};
            float pp[2] = {g->bullet->pp[x][i], g->bullet->pp[y][i]};
            if (wall(g, p, v, g->bullet->m[i])) {
                removeBullet(g->bullet, i);
                continue;
            }
            if (collide(g, p, pp, v, 1, g->you.p, g->you.pp, g->you.v, g->you.m, h)) {
                removeBullet(g->bullet, i);
                continue;
            }
            //check for collisions ith other bullets
            for (int j=i+1; j<30-i; j++) {
                if(g->bullet->p[x][j] != 0){
                    float pj[2] = {g->bullet->p[x][j], g->bullet->p[y][j]};
                    float ppj[2] = {g->bullet->pp[x][j], g->bullet->pp[y][j]};
                    float vj[2] = {g->bullet->v[x][j], g->bullet->v[y][j]};
                    if(collide(g, p, pp, v, 1, pj, ppj, vj, 1, h)){
                        g->bullet->p[x][i] = p[x];
                        g->bullet->p[y][i] = p[y];
                        g->bullet->p[x][i] = pp[x];
                        g->bullet->p[y][i] = pp[y];
                        g->bullet->v[x][i] = v[x];
                        g->bullet->v[y][i] = v[y];
                        
                        g->bullet->p[x][j] = pj[x];
                        g->bullet->p[y][j] = pj[y];
                        g->bullet->pp[x][j] = ppj[x];
                        g->bullet->pp[y][j] = ppj[y];
                        g->bullet->v[x][j] = vj[x];
                        g->bullet->v[y][j] = vj[y];
                        break;
                    }
                }
            }
            //Check for collisions with asteroids
            for(int j=0; j<20; j++){
                if(g->asteroids->p[x][j] != 0){
                    //p = v * t
                    float pj[2] = {g->asteroids->p[x][j], g->asteroids->p[y][j]};
                    float vj[2] = {g->asteroids->v[x][j], g->asteroids->v[y][j]};
                    float ppj[2] = {g->asteroids->pp[x][j], g->asteroids->pp[y][j]};
                    if(collide(g, p, pp, v, 1, pj, ppj, vj, g->asteroids->m[j], h)){
                        g->asteroids->p[x][j] = pj[x];
                        g->asteroids->p[y][j] = pj[y];
                        g->asteroids->pp[x][j] = ppj[x];
                        g->asteroids->pp[y][j] = ppj[y];
                        g->asteroids->v[x][j] = vj[x];
                        g->asteroids->v[y][j] = vj[y];
                        
                        shotAsteroid(g, g->asteroids, j, g->bullet, i);
                        /*g->bullet->p[x][i] = p[x];
                        g->bullet->p[y][i] = p[y];
                        g->bullet->pp[x][i] = p[x];
                        g->bullet->pp[y][i] = p[y];
                        g->bullet->v[x][i] = v[x];
                        g->bullet->v[y][i] = v[y];*/
                        stopLoop = 1;
                        break;
                    }
                }
            }
            if (stopLoop) {
                continue;
            }
            //collision with food
            for(int j=0; j<30; j++){
                if(g->food->p[x][j] != 0){
                    //p = v * t
                    float pj[2] = {g->food->p[x][j], g->food->p[y][j]};
                    float vj[2] = {g->food->v[x][j], g->food->v[y][j]};
                    float ppj[2] = {g->food->pp[x][j], g->food->pp[y][j]};
                    if(collide(g, p, pp, v, 1, pj, ppj, vj, 1, h)){
                        g->food->p[x][j] = pj[x];
                        g->food->p[y][j] = pj[y];
                        g->food->pp[x][j] = ppj[x];
                        g->food->pp[y][j] = ppj[y];
                        g->food->v[x][j] = vj[x];
                        g->food->v[y][j] = vj[y];
                        g->bullet->p[x][i] = p[x];
                        g->bullet->p[y][i] = p[y];
                        g->bullet->pp[x][i] = pp[x];
                        g->bullet->pp[y][i] = pp[y];
                        g->bullet->v[x][i] = v[x];
                        g->bullet->v[y][i] = v[y];
                    }
                }
            }
            
            
            //collision with mfood
            if(collide(g, p, pp, v, 1, g->mFood->p, g->mFood->pp, g->mFood->v, 1, h)){
                g->bullet->p[x][i] = p[x];
                g->bullet->p[y][i] = p[y];
                g->bullet->pp[x][i] = pp[x];
                g->bullet->pp[y][i] = pp[y];
                g->bullet->v[x][i] = v[x];
                g->bullet->v[y][i] = v[y];
            }
        }
    }
}
void updateAteroids(game *g, float h){
    vDSP_mmov(g->asteroids->p, g->asteroids->pp, 20, 2, 20, 20);
    //p = v*∆t + p
    vDSP_vsma(g->asteroids->v[x], 1, &h, g->asteroids->p[x], 1, g->asteroids->p[x], 1, 20);
    vDSP_vsma(g->asteroids->v[y], 1, &h, g->asteroids->p[y], 1, g->asteroids->p[y], 1, 20);
    for(int i=0; i<20; i++){
        if(g->asteroids->p[x][i] != 0){
            
            if (g->asteroids->v[x][i]*g->asteroids->v[x][i]+g->asteroids->v[y][i]*g->asteroids->v[y][i] > 14650) {
                g->asteroids->v[x][i] += -.4/g->crad*g->asteroids->v[x][i]*h;
                g->asteroids->v[y][i] += -.4/g->crad*g->asteroids->v[y][i]*h;
            }
            
            //p = v * t
            float p[2] = {g->asteroids->p[x][i], g->asteroids->p[y][i]};
            float v[2] = {g->asteroids->v[x][i], g->asteroids->v[y][i]};
            float pp[2] = {g->asteroids->pp[x][i], g->asteroids->pp[y][i]};
            wall(g, p, v, g->asteroids->m[i]);
            g->asteroids->p[x][i] = p[x];
            g->asteroids->p[y][i] = p[y];
            g->asteroids->pp[x][i] = p[x];
            g->asteroids->pp[y][i] = p[y];
            g->asteroids->v[x][i] = v[x];
            g->asteroids->v[y][i] = v[y];
            if (collide(g, p, pp, v, g->asteroids->m[i], g->you.p, g->you.pp, g->you.v, g->you.m, h)) {
                g->asteroids->p[x][i] = p[x];
                g->asteroids->p[y][i] = p[y];
                g->asteroids->pp[x][i] = pp[x];
                g->asteroids->pp[y][i] = pp[y];
                g->asteroids->v[x][i] = v[x];
                g->asteroids->v[y][i] = v[y];
                continue;
            }
            //Check for collisions with other asteroids
            for(int j=i+1; j<20; j++){
                if(g->asteroids->p[x][j] != 0){
                    //p = v * t
                    float pj[2] = {g->asteroids->p[x][j], g->asteroids->p[y][j]};
                    float vj[2] = {g->asteroids->v[x][j], g->asteroids->v[y][j]};
                    float ppj[2] = {g->asteroids->pp[x][j], g->asteroids->pp[y][j]};
                    if(collide(g, p, pp, v, g->asteroids->m[i], pj, ppj, vj, g->asteroids->m[j], h)){
                        g->asteroids->p[x][j] = pj[x];
                        g->asteroids->p[y][j] = pj[y];
                        g->asteroids->pp[x][j] = ppj[x];
                        g->asteroids->pp[y][j] = ppj[y];
                        g->asteroids->v[x][j] = vj[x];
                        g->asteroids->v[y][j] = vj[y];
                    }
                }
            }
            //Check for collisions with food
            for(int j=0; j<30; j++){
                if(g->food->p[x][j] != 0){
                    //p = v * t
                    float pj[2] = {g->food->p[x][j], g->food->p[y][j]};
                    float vj[2] = {g->food->v[x][j], g->food->v[y][j]};
                    float ppj[2] = {g->food->pp[x][j], g->food->pp[y][j]};
                    if(collide(g, p, pp, v, g->asteroids->m[i], pj, ppj, vj, 1, h)){
                        g->food->p[x][j] = pj[x];
                        g->food->p[y][j] = pj[y];
                        g->food->pp[x][j] = ppj[x];
                        g->food->pp[y][j] = ppj[y];
                        g->food->v[x][j] = vj[x];
                        g->food->v[y][j] = vj[y];
                        g->asteroids->p[x][i] = p[x];
                        g->asteroids->p[y][i] = p[y];
                        g->asteroids->pp[x][i] = pp[x];
                        g->asteroids->pp[y][i] = pp[y];
                        g->asteroids->v[x][i] = v[x];
                        g->asteroids->v[y][i] = v[y];
                    }
                }
            }
            collide(g, p, pp, v, g->asteroids->m[i], g->mFood->p, g->mFood->pp, g->mFood->v, 1, h);
            g->asteroids->p[x][i] = p[x];
            g->asteroids->p[y][i] = p[y];
            g->asteroids->pp[x][i] = pp[x];
            g->asteroids->pp[y][i] = pp[y];
            g->asteroids->v[x][i] = v[x];
            g->asteroids->v[y][i] = v[y];
        }
    }
}
void updateFood(game *g, float h){
    vDSP_mmov(g->food->p, g->food->pp, 30, 2, 30, 30);
    //v = -4*v*∆t + v
    float dis = -8/g->crad*h;
    vDSP_vsma(g->food->v[x], 1, &dis, g->food->v[x], 1, g->food->v[x], 1, 30);
    vDSP_vsma(g->food->v[y], 1, &dis, g->food->v[y], 1, g->food->v[y], 1, 30);
    //p = v*∆t + p
    vDSP_vsma(g->food->v[x], 1, &h, g->food->p[x], 1, g->food->p[x], 1, 30);
    vDSP_vsma(g->food->v[y], 1, &h, g->food->p[y], 1, g->food->p[y], 1, 30);
    for(int i=0; i<30; i++){
        if(g->food->p[x][i] != 0){
            
            float p[2] = {g->food->p[x][i], g->food->p[y][i]};
            float v[2] = {g->food->v[x][i], g->food->v[y][i]};
            float pp[2] = {g->food->pp[x][i], g->food->pp[y][i]};
            if(wall(g, p, v, 1)){
                g->food->p[x][i] = p[x];
                g->food->p[y][i] = p[y];
                g->food->pp[x][i] = p[x];
                g->food->pp[y][i] = p[y];
                g->food->v[x][i] = v[x];
                g->food->v[y][i] = v[y];
            }
            for(int j=i+1; j<30; j++){
                if(g->food->p[x][j] != 0){
                    //p = v * t
                    float pj[2] = {g->food->p[x][j], g->food->p[y][j]};
                    float vj[2] = {g->food->v[x][j], g->food->v[y][j]};
                    float ppj[2] = {g->food->pp[x][j], g->food->pp[y][j]};
                    if(collide(g, p, pp, v, 1, pj, ppj, vj, 1, h)){
                        g->food->p[x][j] = pj[x];
                        g->food->p[y][j] = pj[y];
                        g->food->pp[x][j] = ppj[x];
                        g->food->pp[y][j] = ppj[y];
                        g->food->v[x][j] = vj[x];
                        g->food->v[y][j] = vj[y];
                        
                        g->food->p[x][i] = p[x];
                        g->food->p[y][i] = p[y];
                        g->food->pp[x][i] = pp[x];
                        g->food->pp[y][i] = pp[y];
                        g->food->v[x][i] = v[x];
                        g->food->v[y][i] = v[y];
                    }
                }
            }
        }
    }
}


