//
//  particle.h
//  knoxoids
//
//  Created by Jonathan Covert on 8/1/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#ifndef __knoxoids__particle__
#define __knoxoids__particle__

#include <iostream>
#include "vector.h"

class particle {
public:
    vector<double> pos;
    vector<double> vel;
    vector<double> initialVel;
    float life;
    float size;
    bool isAlive;
};
struct color {
    float r;
    float g;
    float b;
};

struct particleSysDef {
    vector<double> pos;
    color color;
    int numOfParts;
    vector<double> vel;
};

class particleSystem {
public:
    particle **parts;
    int numParts;
    
    bool dead;
    
    color color;
    vector<double> basePosition;
    particleSystem(particleSysDef);
    void update(float eTime);
    
    ~particleSystem();
};


#endif /* defined(__knoxoids__particle__) */
