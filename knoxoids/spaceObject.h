//
//  spaceObject.h
//  knoxoids
//
//  Created by Jonathan Covert on 6/17/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//
#include "gameGlobals.h"
#include "vector.h"

#ifndef knoxoids_spaceObject_h
#define knoxoids_spaceObject_h

class soundSource;
class openAL;
class game;

class spaceObject{
    public:
        vector<double> pos;
        vector<double> vel;
        
        vector<double> ppos;
        int remove;
        int mass;
        
        soundSource *sound;
        game *currentGame;
    
        BOOL isInvisable;
    
        //updates the objects position
        virtual void update(double);
    
        int wall();
        
        double size();
        
        //return the time of collision on hit, -1 if they didn't
        double didHit(spaceObject *, double eTime);
        int collision(spaceObject *, double eTime);
        
        spaceObject (game *currentGame);
        spaceObject (int m, game *currentGame);
        spaceObject (int m, vector<double> position, game *currentGame);
        spaceObject (int m, vector<double> position, vector<double> velocity, game *currentGame);
        
        ~spaceObject();
};

#endif
