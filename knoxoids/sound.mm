//
//  sound.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 7/30/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include "sound.h"

bool soundSource::update(){
    int isplaying = AL_PLAYING;
    alGetSourcei(source, AL_SOURCE_STATE, &isplaying);
    if (isplaying == AL_STOPPED || sObject == NULL) {
        if (sObject!=NULL) {
            if (sObject->sound == this) {
                sObject->sound = NULL;
            }
        }
        return false;
    }
    if (bufferType < alBuffer_num) {
        alSource3f(source, AL_POSITION, sObject->pos.x, sObject->pos.y, 0);
        alSource3f(source, AL_VELOCITY, sObject->vel.x, sObject->vel.y, 0);
    }
    return true;
}

soundSource::~soundSource(){
    alDeleteSources(1, &source);
    
    if (shouldFreeSpaceObject) {
        delete sObject;
    }
}