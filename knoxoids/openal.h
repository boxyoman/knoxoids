//
//  openal.h
//  knoxoids
//
//  Created by Jonathan Covert on 7/30/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#ifndef __knoxoids__openal__
#define __knoxoids__openal__

#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/ExtendedAudioFile.h>
#include <iostream>
#include "spaceObject.h"

enum soundBuffers{
    alBuffer_boom,
    alBuffer_youShoot,
    alBuffer_guidedTurretShoot,
    alBuffer_guidedBullet,
    alBuffer_alienShoot,
    alBuffer_regularTurretShoot,
    alBuffer_eat,
    alBuffer_bounce,
    alBuffer_num
};

class soundSource;

class openAL {
    ALCuint buffers[alBuffer_num];
    ALCdevice *device;
    ALCcontext *context;
    
public:
    void initSound(void);
    
    soundSource* createSoundSource(spaceObject *object, soundBuffers bufferType, bool isLooping, bool shouldFreeSpaceObject);
    void deleteSource(soundSource *source);
    spaceObject *listener;
    soundSource **sounds;
    int sourceNum;
    
    bool playSouds;
    
    void update();
    ~openAL();
private:
    void addSource(soundSource *source);
    void updateListener();
    SInt16* getSoundData(NSURL* url, SInt64* frameNum);
    void initBuffers(void);
};

#endif /* defined(__knoxoids__openal__) */
