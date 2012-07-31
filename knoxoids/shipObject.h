//
//  shipObject.h
//  knoxoids
//
//  Created by Jonathan Covert on 6/18/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#ifndef knoxoids_shipObject_h
#define knoxoids_shipObject_h
#include "spaceObject.h"
#include "bulletObject.h"
#include "foodObject.h"
#include "openal.h"
#include "sound.h"

enum shipType {
    yourShip,
    alienShip,
    regularTurret,
    guidedTurret
};

class shipObject: public spaceObject{
    public:
        vector<double> thrust;
        double ang;
        
    
        void update(double);
        
        int gunOn;
        float diedTime;
        bulletObject* shoot();
        void destroy();
        void ate();
        
        shipType type;
    
        shipObject(game *currentGame):spaceObject(currentGame){
            gunOn = 1;
            ang = 0;
        };
        
        shipObject(int m, game *currentGame): spaceObject(m, currentGame){
            gunOn = 1;
            ang = 0;
        };
        shipObject(int m, vector<double> position, game *currentGame): spaceObject (m, position, currentGame){
            gunOn = 1;
            ang = 0;
        };
};


#endif