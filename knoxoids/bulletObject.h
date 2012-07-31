//
//  bullet.h
//  knoxoids
//
//  Created by Jonathan Covert on 6/23/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#ifndef knoxoids_bullet_h
#define knoxoids_bullet_h

#include "spaceObject.h"
#include "gameGlobals.h"
#include "openal.h"
#include "sound.h"

class bulletObject: public spaceObject{
    public:
        void update(double);
        bulletObject(game *currentGame): spaceObject(currentGame){
            mass = 1;
        }
        
};

#endif
