//
//  asteroidObject.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 6/25/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include "asteroidObject.h"
#include "game.h"

void astObject::destroy(){
    currentGame->openal->createSoundSource(this, alBuffer_boom, false, false);
    
    float ang = 2*M_PI/(float)mass;
    float s = size();
    for (int i = 0; i<mass; i++) {
        vector<double> position = vector<double>(cos(ang*i)*(s-1),sin(ang*i)*(s-1));
        position = position+pos;
        
        vector<double> velocity = vector<double>(vel.x/mass+cos(ang*i)*20, vel.y/mass+cos(ang*i)*20);
        currentGame->addFood(new foodObject(position, velocity, currentGame));
    }
}

void astObject::splitAsteroid(float ang){
    astObject *ast = new astObject(currentGame);
    
    currentGame->openal->createSoundSource(this, alBuffer_boom, false, false);
    
    if (mass%2 == 0) {
        ast->mass = mass/2;
        mass = mass/2;
    }else{
        ast->mass = mass/2-.5;
        mass = mass/2+.5;
    }
    
    
    vector<double> unit(ang+M_PI_2);
    ast->pos = pos+unit*(ast->size()+1);
    ast->vel = vel+unit*15;
    
    pos = pos-unit*size();
    vel = vel-unit*15;
    
    currentGame->addAsteroid(ast);
}