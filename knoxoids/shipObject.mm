//
//  shipObject.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 6/18/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include <iostream>
#include "shipObject.h"
#include "game.h"

void shipObject::update(double eTime){
    if(wall()){
        gunOn = 0;
    }
    
    ppos = pos;
    vel = vel + (vel*-.05*M_PI*size()*size() + thrust)*eTime;
    pos = pos + vel * eTime;
}

void shipObject::ate(){
    if (gunOn==1) {
        mass++;
    }else{
        gunOn=1;
    }
}

bulletObject* shipObject::shoot(){
    if (gunOn) {
        currentGame->openal->createSoundSource(this, alBuffer_youShoot, false, false);
        
        bulletObject *bullet = new bulletObject(currentGame);
        float s = size()+1;
        
        bullet->pos.x = pos.x+cos(ang)*s;
        bullet->pos.y = pos.y+sin(ang)*s;
        bullet->vel.x = vel.x+cos(ang)*125;
        bullet->vel.y = vel.y+sin(ang)*125;
        
        vel = (vel*(1+mass) - bullet->vel) * (1.0/mass);
        
        if (mass == 3 && gunOn) {
            gunOn = 0;
        }else {
            mass --;
        }
        return bullet;
    }else {
        return NULL;
    }
}

foodObject** shipObject::destroy(){
    diedTime = globals::gameTime;
    
    foodObject **food = (foodObject**)malloc(sizeof(foodObject**)*mass);
    
    float ang = 2*M_PI/(float)mass;
    float s = size();
    for (int i = 0; i<mass; i++) {
        vector<double> position = vector<double>(cos(ang*i)*(s-1),sin(ang*i)*(s-1));
        position = position+pos;
        
        vector<double> velocity = vector<double>(vel.x/mass+cos(ang*i)*10, vel.y/mass+cos(ang*i)*10);
        food[i] = new foodObject(position, velocity, currentGame);
    }
    return food;
}