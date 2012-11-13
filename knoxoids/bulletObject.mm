//
//  bullet.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 6/23/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include <iostream>
#include "bulletObject.h"
#include "game.h"
#include "shipObject.h"


void bulletObject::update(double eTime){
    if (wall()) {
        remove = 1;
        particleSysDef partDef;
        partDef.pos = this->pos;
        partDef.vel = this->vel;
        if (target==NULL) {
            partDef.color.r = 0.64f;
        }else{
            partDef.color.r = 1.0f;
        }
        partDef.color.g = 0.16f;
        partDef.color.b =  0.47f;
        partDef.numOfParts = 20;
        currentGame->partSysMan->createNewSystem(partDef);
    }
    
    if (target!=NULL && sound == NULL) {
        sound = currentGame->openal->createSoundSource(this, alBuffer_guidedBullet, true, false);
    }
    
    ppos = pos;
    if (target != NULL) {
        vel = vel + (target->pos-pos).unit()*eTime*160;
        if (vel.mag2() > 3600) {
            vel = vel.unit()*60;
        }
    }
    pos = pos + vel * eTime;
}