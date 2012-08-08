//
//  particle.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 8/1/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include "particle.h"
#include <ctime>

particleSystem::particleSystem(particleSysDef partSysDef){
    basePosition = partSysDef.pos;
    color = partSysDef.color;
    numParts = partSysDef.numOfParts;
    parts = (particle**)malloc(sizeof(particle*)*numParts);
    
    vector<double> velUnit = partSysDef.vel.unit();
    float velMag = sqrt(partSysDef.vel.mag());
    
    dead = false;
    
    for (int i=0; i<numParts; i++) {
        parts[i] = new particle;
        parts[i]->pos=basePosition;
        float randAng = rand()/(float)RAND_MAX*M_PI*2;
        float randMag = rand()/(float)RAND_MAX*velMag;
        vector<double> randAngVect(randAng);
        parts[i]->vel = (velUnit - randAngVect) * randMag*randMag;
        parts[i]->initialVel = parts[i]->vel;
        parts[i]->life = 1;
        parts[i]->size = rand()/(float)RAND_MAX*4+.5;
    }
}

void particleSystem::update(float eTime){
    int deadParticles=0;
    for (int i=0; i<numParts; i++) {
        if (parts[i]->life>0.0003) {
            parts[i]->vel = parts[i]->vel + (parts[i]->vel*-2.0*M_PI)*eTime;
            parts[i]->pos = parts[i]->pos + parts[i]->vel*eTime;
            parts[i]->life = parts[i]->vel.mag()/parts[i]->initialVel.mag();
        }else{
            deadParticles++;
            parts[i]->life = 0;
        }
    }
    if (deadParticles == numParts) {
        dead = true;
    }
}

particleSystem::~particleSystem(){
    for (int i=0; i<numParts; i++) {
        delete parts[i];
    }
    free(parts);
}