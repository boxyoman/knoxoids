//
//  particleSystemManager.h
//  knoxoids
//
//  Created by Jonathan Covert on 8/1/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#ifndef __knoxoids__particleSystemManager__
#define __knoxoids__particleSystemManager__

#include <iostream>
#include "particle.h"

class particleSysManager {
public:
    particleSysManager();
    void update(float eTime);
    particleSystem **partSystems;
    int numPartSys;
    particleSystem* createNewSystem(particleSysDef);
private:
    void addPartSys(particleSystem*);
};

#endif /* defined(__knoxoids__particleSystemManager__) */
