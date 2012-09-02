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

#define turretWaitTime 4

void shipObject::update(double eTime){
    if(wall()){
        if (type == yourShip || type ==  alienShip) {
            gunOn = 0;
            if (type == yourShip) {
                currentGame->openal->createSoundSource(this, alBuffer_bounce, false, false);
            }
        }
    }
    
    ppos = pos;
    vel = vel + (vel*-.05*M_PI*size()*size() + thrust)*eTime;
    pos = pos + vel * eTime;
    
    if (type == alienShip) {
        thrust = (currentGame->mfood->pos-pos).unit()*20;
        if (vel.mag2() > 900) {
            vel = vel.unit()*30;
        }
        ang = pos.angle(currentGame->you->pos);
    }
    
    if (type == regularTurret || type == guidedTurret) {
        if (shootTime+turretWaitTime<globals::gameTime) {
            if (currentGame->you->remove == 0) {
                gunOn = 1;
                shoot();
            }
        }
        ang = pos.angle(currentGame->you->pos);
    }
    
}
void shipObject::eat(foodObject *food){
    if (food->remove == 0) {
        if (type == yourShip) {
            if (food->type == lifeFood) {
                currentGame->lives++;
            }else if (food->type == sheildFood){
                sheildOn = true;
                sheildOnTime = globals::gameTime;
            }else{
                ate();
            }
        }else{
            ate();
        }
        food->remove = 1;
    }
}
void shipObject::ate(){
    currentGame->openal->createSoundSource(this, alBuffer_eat, false, false);
    if (gunOn==1) {
        mass++;
    }else{
        gunOn=1;
    }
}

bool shipObject::shoot(){
    if (gunOn == 1) {
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
                //currentGame->openal->createSoundSource(this, alBuffer_guidedTurretShoot, false, false);
                target = currentGame->you;
                break;
            default:
                break;
        }
        
        bulletObject *bullet = new bulletObject(currentGame);
        float s = size()+1;
        float shootSpeed = 125;
        if (type == guidedTurret) {
            shootSpeed = 25;
        }
        
        bullet->pos.x = pos.x+cos(ang)*s;
        bullet->pos.y = pos.y+sin(ang)*s;
        bullet->ppos = bullet->pos;
        bullet->vel.x = vel.x+cos(ang)*shootSpeed;
        bullet->vel.y = vel.y+sin(ang)*shootSpeed;
        bullet->target = target;
        
        vel = (vel*(1+mass) - bullet->vel) * (1.0/mass);
        
        if (mass == 3 && gunOn) {
            gunOn = 0;
        }else {
            mass --;
        }
        currentGame->addBullet(bullet);
        
        particleSysDef partDef;
        partDef.pos = pos;
        partDef.vel = bullet->vel;
        if (target==NULL) {
            partDef.color.r = 0.64f;
        }else{
            partDef.color.r = 1.0f;
        }
        partDef.color.g = 0.16f;
        partDef.color.b =  0.47f;
        partDef.numOfParts = 3;
        currentGame->partSysMan->createNewSystem(partDef);
        
        shootTime = globals::gameTime;
        return true;
    }else {
        return false;
    }
}
bool shipObject::shot(bulletObject* bullet){
    if (sheildOn == true) {
        particleSysDef partDef;
        partDef.pos = bullet->pos;
        partDef.vel = bullet->vel;
        partDef.color.r = 0.0f;
        partDef.color.g = 0.0f;
        partDef.color.b =  1.0f;
        partDef.numOfParts = 20;
        currentGame->partSysMan->createNewSystem(partDef);
        
        return false;
    }else{
        bullet->remove = 1;
        
        particleSysDef partDef;
        partDef.pos = bullet->pos;
        partDef.vel = bullet->vel;
        if (bullet->target==NULL) {
            partDef.color.r = 0.64f;
        }else{
            partDef.color.r = 1.0f;
        }
        partDef.color.g = 0.16f;
        partDef.color.b =  0.47f;
        partDef.numOfParts = 20;
        currentGame->partSysMan->createNewSystem(partDef);
        
        if (mass>5) {
            mass--;
            return false;
        }else{
            destroy();
            remove = 1;
            return true;
        }
    }
}
void shipObject::destroy(){
    if (sheildOn == false) {
        currentGame->openal->createSoundSource(this, alBuffer_boom, false, false);
        
        diedTime = globals::gameTime;
        
        float ang = 2*M_PI/(float)mass;
        float s = size();
        for (int i = 0; i<mass; i++) {
            vector<double> position = vector<double>(cos(ang*i)*(s-1),sin(ang*i)*(s-1));
            position = position+pos;
            
            vector<double> velocity = vector<double>(vel.x/mass+cos(ang*i)*-10, vel.y/mass+cos(ang*i)*-10);
            currentGame->addFood(new foodObject(position, velocity, currentGame));
        }
        remove = 1;
    }
}