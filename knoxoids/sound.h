//
//  sound.h
//  knoxoids
//
//  Created by Jonathan Covert on 7/30/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#ifndef __knoxoids__sound__
#define __knoxoids__sound__

#include "openal.h"
#include <iostream>
#include "spaceObject.h"

class soundSource {
public:
    ALCuint source;
    int bufferType;
    spaceObject* sObject;
    bool isLooping;
    
    bool shouldFreeSpaceObject;
    
    bool update();
    ~soundSource();
};

#endif /* defined(__knoxoids__sound__) */
