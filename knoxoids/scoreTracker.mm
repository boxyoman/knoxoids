//
//  scoreTracker.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 10/1/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include "scoreTracker.h"

scoreTracker::scoreTracker(){
    score = 0;
}

void scoreTracker::init(){
    //Game Center login
    player = [GKLocalPlayer localPlayer];
    [player authenticateWithCompletionHandler:^(NSError *err){
        if (player.isAuthenticated) {
            NSLog(@"Logged-in successfully\n");
        }else{
            NSLog(@"Error authenticating player \n");
        }
    }];
}

void scoreTracker::operator+=(int s){
    score += s;
}

void scoreTracker::resetScore(){
    score = 0;
}

