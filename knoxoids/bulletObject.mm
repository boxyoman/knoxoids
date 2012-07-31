//
//  bullet.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 6/23/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include <iostream>
#include "bulletObject.h"
#include "game.h"

void bulletObject::update(double eTime){
    if (wall()) {
        //need to remove bullet
        remove = 1;
    }
    
    ppos = pos;
    pos = pos + vel * eTime;
}