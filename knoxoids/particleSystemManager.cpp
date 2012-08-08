//
//  particleSystemManager.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 8/1/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include "particleSystemManager.h"

particleSysManager::particleSysManager(){
    numPartSys = 2;
    partSystems = (particleSystem**)malloc(sizeof(particleSystem*)*numPartSys);
    for (int i=0; i<numPartSys; i++) {
        partSystems[i] = NULL;
    }
}

void particleSysManager::update(float eTime){
    for (int i=0; i<numPartSys; i++) {
        if (partSystems[i]!=NULL) {
            partSystems[i]->update(eTime);
            if (partSystems[i]->dead) {
                delete partSystems[i];
                partSystems[i] = NULL;
            }
        }
    }
}

particleSystem* particleSysManager::createNewSystem(particleSysDef partSysDef){
    particleSystem *partSys = new particleSystem(partSysDef);
    addPartSys(partSys);
    return partSys;
}

void particleSysManager::addPartSys(particleSystem* partSys){
    int opening = -1;
    for (int i=0; i<numPartSys; i++) {
        if (partSystems[i] == NULL) {
            opening = i;
        }
    }
    if (opening == -1) {
        numPartSys ++;
        partSystems = (particleSystem**)realloc(partSystems, sizeof(particleSystem*)*numPartSys);
        partSystems[numPartSys-1] = partSys;
    }else{
        partSystems[opening] = partSys;
    }
}