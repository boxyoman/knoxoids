//
//  scoreTracker.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 9/18/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

//
//  scoreTracker.h
//  knoxoids
//
//  Created by Jonathan Covert on 9/18/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#ifndef __knoxoids__scoreTracker__
#define __knoxoids__scoreTracker__

#import <GameKit/GameKit.h>

class scoreTracker {
    GKLocalPlayer *player;
    
public:
    scoreTracker();
    void init();
    int score;
    void uploadScore();
    void resetScore();
    void operator += (int s);
};


#endif /* defined(__knoxoids__scoreTracker__) */




