//
//  foodObject.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 6/25/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include "foodObject.h"
#include "game.h"

void foodObject::update(double eTime){
    wall();
    
    ppos = pos;
    vel = vel + (vel*-1.1*M_PI)*eTime;
    pos = pos + vel * eTime;
    
    if (bornTime+foodLife<globals::gameTime&&shouldBeRemoved == true) {
        remove=1;
    }
}