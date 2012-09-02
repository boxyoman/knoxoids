//
//  foodObject.h
//  knoxoids
//
//  Created by Jonathan Covert on 6/25/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#ifndef __knoxoids__foodObject__
#define __knoxoids__foodObject__
#define foodLife 15
#include <iostream>
#include "spaceObject.h"
#include "openal.h"
#include "sound.h"

enum foodType {
    regularFood,
    sheildFood,
    lifeFood
};

class foodObject: public spaceObject{
    public:
        float bornTime;
        bool shouldBeRemoved;
        foodType type;
        
        foodObject(game *currentGame): spaceObject (1, currentGame){
            type = regularFood;
            bornTime=globals::gameTime;
            shouldBeRemoved=true;
        };
        
        foodObject(vector<double> position, game *currentGame): spaceObject (1, position, currentGame){
            bornTime=globals::gameTime;
            shouldBeRemoved=true;
        };
        foodObject(vector<double> position, vector<double> velocity, game *currentGame): spaceObject (1, position, velocity, currentGame){
            bornTime=globals::gameTime;
            shouldBeRemoved=true;
        };
        
        void update(double eTime);
};

#endif /* defined(__knoxoids__foodObject__) */
