//
//  openal.mm
//  knoxoids
//
//  Created by Jonathan Covert on 7/30/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include "openal.h"
#include "sound.h"

void openAL::initSound(void){
    alGetError();
    device = alcOpenDevice(NULL);
    
    if (device != NULL) {
        context = alcCreateContext(device, NULL);
        
        if (context != NULL) {
            alcMakeContextCurrent(context);
            alEnable(AL_DISTANCE_MODEL);
            alEnable(AL_SPEED_OF_SOUND);
            alEnable(AL_DOPPLER_FACTOR);
            alDopplerFactor(1);
            alDistanceModel(AL_INVERSE_DISTANCE_CLAMPED);
            alSpeedOfSound(1000);
            initBuffers();
            
            sourceNum = 10;
            sounds = (soundSource**)malloc(sizeof(soundSource*)*sourceNum);
            for (int i=0; i<sourceNum; i++) {
                sounds[i]=NULL;
            }
            playSouds = false;
        }else{
            printf("Context Error");
        }
        
    }else{
        printf("Device error.\n");
    }
}

void openAL::initBuffers(void){
    //ALuint source;
    alGenBuffers(alBuffer_num, buffers);
    NSBundle *bundle = [NSBundle mainBundle];
    
    SInt16* data = NULL;
    SInt64 frameNum = 0;
    UInt32 dataSize = 0;
    
    //Get audio data
    data = getSoundData([bundle URLForResource:@"boom2" withExtension:@"m4a"], &frameNum);
    if (data == NULL) {
        printf("Error getting audio data from boom.m4a");
    }
    
    dataSize = frameNum * sizeof(SInt16);
    
    //Load data into buffer
    alBufferData(buffers[alBuffer_boom], AL_FORMAT_MONO16, data, dataSize, 44100);
    
    free(data);
    
    //Get audio data
    data = getSoundData([bundle URLForResource:@"shoot" withExtension:@"m4a"], &frameNum);
    if (data == NULL)
        printf("Error getting audio data from shoot.m4a");
    
    dataSize = frameNum * sizeof(SInt16);
    //Load data into buffer
    alBufferData(buffers[alBuffer_youShoot], AL_FORMAT_MONO16, data, dataSize, 44100);
    
    free(data);
    
    //Get audio data
    data = getSoundData([bundle URLForResource:@"guidedShoot" withExtension:@"m4a"], &frameNum);
    if (data == NULL)
        printf("Error getting audio data from guidedShoot.m4a");
    
    dataSize = frameNum * sizeof(SInt16);
    //Load data into buffer
    alBufferData(buffers[alBuffer_guidedTurretShoot], AL_FORMAT_MONO16, data, dataSize, 44100);
    
    free(data);
    
    //get audio data
    data = getSoundData([bundle URLForResource:@"guidedBullet2" withExtension:@"m4a"], &frameNum);
    if (data == NULL)
        printf("Error getting audio data from guidedBullet2.m4a");
    
    dataSize = frameNum * sizeof(SInt16);
    //Load data into buffer
    alBufferData(buffers[alBuffer_guidedBullet], AL_FORMAT_MONO16, data, dataSize, 44100);
    
    free(data);
    
    //get audio data
    data = getSoundData([bundle URLForResource:@"alienShoot" withExtension:@"m4a"], &frameNum);
    if (data == NULL)
        printf("Error getting audio data from alienShoot.m4a");
    
    dataSize = frameNum * sizeof(SInt16);
    //Load data into buffer
    alBufferData(buffers[alBuffer_alienShoot], AL_FORMAT_MONO16, data, dataSize, 44100);
    
    free(data);
    
    //get audio data
    data = getSoundData([bundle URLForResource:@"turretShoot" withExtension:@"m4a"], &frameNum);
    if (data == NULL)
        printf("Error getting audio data from turretShoot.m4a");
    
    dataSize = frameNum * sizeof(SInt16);
    //Load data into buffer
    alBufferData(buffers[alBuffer_regularTurretShoot], AL_FORMAT_MONO16, data, dataSize, 44100);
    
    free(data);
    
    
    //get audio data
    data = getSoundData([bundle URLForResource:@"eat2" withExtension:@"m4a"], &frameNum);
    if (data == NULL)
        printf("Error getting audio data from eat.m4a");
    
    dataSize = frameNum * sizeof(SInt16);
    //Load data into buffer
    alBufferData(buffers[alBuffer_eat], AL_FORMAT_MONO16, data, dataSize, 44100);
    
    free(data);
    
    //get audio data
    data = getSoundData([bundle URLForResource:@"bounce" withExtension:@"m4a"], &frameNum);
    if (data == NULL)
        printf("Error getting audio data from eat.m4a");
    
    dataSize = frameNum * sizeof(SInt16);
    //Load data into buffer
    alBufferData(buffers[alBuffer_bounce], AL_FORMAT_MONO16, data, dataSize, 44100);
    
    free(data);
}

soundSource* openAL::createSoundSource(spaceObject *object, soundBuffers bufferType, bool isLooping, bool shouldFreeSpaceObject){
    if (playSouds == true) {
        soundSource *source = new soundSource;
        
        source->sObject = object;
        source->bufferType = bufferType;
        source->shouldFreeSpaceObject = shouldFreeSpaceObject;
        
        alGenSources(1, &source->source);
        alSourcei(source->source, AL_BUFFER, buffers[bufferType]);
        alSource3f(source->source, AL_POSITION, object->pos.x, object->pos.y, 0.0);
        alSource3f(source->source, AL_VELOCITY, object->vel.x, object->vel.y, 0.0);
        alSourcePlay(source->source);
        alSourcei(source->source, AL_REFERENCE_DISTANCE, 100);
        
        if (isLooping) {
            alSourcei(source->source, AL_LOOPING, AL_TRUE);
        }
        
        addSource(source);
        
        return source;
    }else{
        return NULL;
    }
}

void openAL::addSource(soundSource *source){
    int opening=-1;
    for (int i=0; i<sourceNum; i++) {
        if (sounds[i]==NULL) {
            opening = i;
            break;
        }
    }
    if (opening==-1) {
        sourceNum++;
        sounds = (soundSource**)realloc(sounds, sizeof(soundSource*)*(sourceNum));
        sounds[sourceNum-1] = source;
    }else{
        sounds[opening]=source;
    }
}
void openAL::deleteSource(soundSource *source){
    for (int i=0; i<sourceNum; i++) {
        if (sounds[i]==source) {
            delete source;
            sounds[i] = NULL;
        }
    }
}
void openAL::update(){
    updateListener();
    for (int i=0; i<sourceNum; i++) {
        if (sounds[i]!=NULL) {
            if(sounds[i]->update() == false){
                deleteSource(sounds[i]);
            }
        }
    }
}

void openAL::updateListener(){
    ALfloat listenerP[] = {listener->pos.x, listener->pos.y, 0.0};
    ALfloat listenerV[] = {listener->vel.x, listener->vel.y, 0.0};
    
    alListenerfv(AL_POSITION, listenerP);
    alListenerfv(AL_VELOCITY, listenerV);
}

SInt16* openAL::getSoundData(NSURL* url, SInt64* frame){
    //Get audio data
    ExtAudioFileRef ref;
    UInt32 flags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    
    CFURLRef cfurl = (__bridge CFURLRef)url;
    
    int b;
    
    if ((b = ExtAudioFileOpenURL(cfurl, &ref)) != 0){
        printf("open file error: %d", b);
    }
    
    
    SInt64 frameNum = 0;
    UInt32 sizeOfUInt32 = sizeof(frameNum);
    ExtAudioFileGetProperty(ref, kExtAudioFileProperty_FileLengthFrames, &sizeOfUInt32, &frameNum);
    
    //printf("%lld\n", frameNum);
    
    AudioStreamBasicDescription desc = {44100., kAudioFormatLinearPCM, flags, 2, 1, 2, 1, 16, 0};
    ExtAudioFileSetProperty(ref, kExtAudioFileProperty_ClientDataFormat, sizeof(desc), &desc);
    
    UInt32 dataSize = frameNum * sizeof(SInt16);
    
    SInt16* data = (SInt16*) malloc(dataSize);
    
    AudioBufferList abl;
    abl.mNumberBuffers = (UInt32) 1;
    abl.mBuffers[0].mDataByteSize = dataSize;
    abl.mBuffers[0].mData = data;
    abl.mBuffers[0].mNumberChannels = 1;
    
    ExtAudioFileRead(ref, (UInt32 *)&frameNum, &abl);
    
    *frame = frameNum;
    return data;
}

openAL::~openAL(){
    alDeleteBuffers(alBuffer_num, buffers);
    
    alcMakeContextCurrent(NULL);
    alcDestroyContext(context);
    alcCloseDevice(device);
    
    for (int i=0; i<sourceNum; i++) {
        if (sounds[i]!=NULL) {
            delete sounds[i];
        }
    }
    free(sounds);
}