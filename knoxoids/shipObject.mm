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
        currentGame->openal->createSoundSource(this, alBuffer_bounce, false, false);
    }
    
    ppos = pos;
    vel = vel + (vel*-.05*M_PI*size()*size() + thrust)*eTime;
    pos = pos + vel * eTime;
}

void shipObject::ate(){
    currentGame->openal->createSoundSource(this, alBuffer_eat, false, false);
    if (gunOn==1) {
        mass++;
    }else{
        gunOn=1;
    }
}

bulletObject* shipObject::shoot(){
    if (gunOn) {
        spaceObject *target = NULL;
        switch (type) {
            case alienShip:
                currentGame->openal->createSoundSource(this, alBuffer_alienShoot, false, false);
                break;
            case yourShip:
                currentGame->openal->createSoundSource(this, alBuffer_youShoot, false, false);
                break;
            case regularTurret:
                currentGame->openal->createSoundSource(this, alBuffer_regularTurretShoot, false, false);
                break;
            case guidedTurret:
                currentGame->openal->createSoundSource(this, alBuffer_guidedTurretShoot, false, false);
                target = currentGame->you;
                break;
            default:
                break;
        }
        
        bulletObject *bullet = new bulletObject(currentGame);
        float s = size()+1;
        
        bullet->pos.x = pos.x+cos(ang)*s;
        bullet->pos.y = pos.y+sin(ang)*s;
        bullet->vel.x = vel.x+cos(ang)*125;
        bullet->vel.y = vel.y+sin(ang)*125;
        
        bullet->target = target;
        
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

void shipObject::destroy(){
    currentGame->openal->createSoundSource(this, alBuffer_boom, false, false);
    
    diedTime = globals::gameTime;
    
    float ang = 2*M_PI/(float)mass;
    float s = size();
    for (int i = 0; i<mass; i++) {
        vector<double> position = vector<double>(cos(ang*i)*(s-1),sin(ang*i)*(s-1));
        position = position+pos;
        
        vector<double> velocity = vector<double>(vel.x/mass+cos(ang*i)*10, vel.y/mass+cos(ang*i)*10);
        currentGame->addFood(new foodObject(position, velocity, currentGame));
    }
}