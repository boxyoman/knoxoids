//
//  asteroidObject.h
//  knoxoids
//
//  Created by Jonathan Covert on 6/25/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#ifndef __knoxoids__asteroidObject__
#define __knoxoids__asteroidObject__

#include <iostream>
#include "spaceObject.h"
#include "foodObject.h"
#include "bulletObject.h"
#include "openal.h"
#include "sound.h"

class astObject: public spaceObject{
    public:
        astObject(game *currentGame):spaceObject (currentGame){};
        astObject(int m, game *currentGame): spaceObject (m, currentGame){};
        astObject(int m, vector<double> position, game *currentGame): spaceObject (m, position, currentGame){};
        astObject(int m, vector<double> position, vector<double> velocity, game *currentGame): spaceObject (m, position, velocity, currentGame){};
        
        void destroy(bulletObject*);
        void splitAsteroid(float ang);
};

#endif /* defined(__knoxoids__asteroidObject__) */
