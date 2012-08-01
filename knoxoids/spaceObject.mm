//
//  spaceObject.cpp
//  knoxoids
//
//  Created by Jonathan Covert on 6/17/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#include <iostream>
#include "spaceObject.h"
#include "openal.h"
#include "sound.h"
#include "game.h"

spaceObject::spaceObject (game *g){
    pos = vector<double>(0.0, 0.0);
    ppos = pos;
    vel = vector<double>(0.0, 0.0);
    mass = 3;
    remove = 0;
    sound = NULL;
    currentGame = g;
}
spaceObject::spaceObject (int m, game *g){
    pos = vector<double>(0.0, 0.0);
    ppos=pos;
    vel = vector<double>(0.0, 0.0);
    mass = m;
    remove = 0;
    sound = NULL;
    currentGame = g;
}
spaceObject::spaceObject (int m, vector<double> position, game *g){
    pos = position;
    ppos=pos;
    vel = vector<double>(0.0, 0.0);
    mass = m;
    remove = 0;
    sound = NULL;
    currentGame = g;
}
spaceObject::spaceObject (int m, vector<double> position, vector<double> velocity, game *g){
    pos = position;
    ppos=pos;
    vel = velocity;
    mass = m;
    remove = 0;
    sound = NULL;
    currentGame = g;
}

int spaceObject::wall(){
    double s = size();
    if (pos.x-s <= 0) {
        vel.x = vel.x*-1;
        pos.x = s;
        return 1;
    }
    if (pos.x+s >= globals::width) {
        vel.x = vel.x*-1;
        pos.x = globals::width-s;
        return 1;
    }
    if (pos.y-s <= 0) {
        vel.y = vel.y*-1;
        pos.y = s;
        return 1;
    }
    if (pos.y+s >= globals::height) {
        vel.y = vel.y*-1;
        pos.y = globals::height-s;
        return 1;
    }
    return 0;
}

void spaceObject::update(double eTime){
    wall();
    
    ppos = pos;
    
    if (vel.mag2()>4900) {
        vel = vel + (vel*-.05*M_PI*size()*size())*eTime;
    }
    pos = pos + vel * eTime;
}

double spaceObject::size(){
    if(mass <=1){
		return mass;
	}
	else{
		return 1/(cos(M_PI*(mass-2)/(2*mass)))+1;
	}
}

double spaceObject::didHit(spaceObject *obj, double eTime){
    vector<double> v1 = (pos - ppos)/eTime;
    vector<double> v2 = (obj->pos - obj->ppos)/eTime;
    
    vector<double> relativeVel = v1-v2;
    vector<double> relPos = obj->ppos - ppos;
    
    //See if the two objects are moving towards eachother
    if (relPos.dot(relativeVel) > 0) {
        vector<double> relVel = relativeVel*-1;
        double dist = obj->size() + this->size()+.0001;
        
        // d = √( (relPos.x+relVel.x*t)^2 + (relPos.y+relVel.y*t)^2 )
        // solved for t, pick smallest t
        // see if t < eTime
        
        double disc = 2*relPos.x*relPos.y*relVel.x*relVel.y + (dist*dist -relPos.y*relPos.y)*relVel.x*relVel.x + (dist*dist - relPos.x*relPos.x)*relVel.y*relVel.y;
        if(disc >= 0){
            double time1=-(relPos.x*relVel.x + relPos.y*relVel.y + sqrt(disc))/(relVel.x*relVel.x + relVel.y*relVel.y);
            double time2=-(relPos.x*relVel.x + relPos.y*relVel.y - sqrt(disc))/(relVel.x*relVel.x + relVel.y*relVel.y);
            
            if(time1 <= time2 && time1 <= eTime && (time1>=0 || time2>=0)){
                return time1;
            }else if(time2 <= eTime && time2>=0){
                return time2;
            }else{
                return -1;
            }
        }else{
            return -1;
        }
    }else{
        return -1;
    }
}

int spaceObject::collision(spaceObject *obj, double eTime){
    if (obj !=NULL && obj->remove==0) {
        double time;
        time = didHit(obj, eTime);
        if (time != -1) {
            vector<double> v1 = (pos - ppos)/eTime;
            vector<double> v2 = (obj->pos - obj->ppos)/eTime;
            
            vector<double> p1 = ppos+v1*time;
            vector<double> p2 = obj->ppos+v2*time;
            
            pos=p1;
            ppos=p1;
            obj->pos=p2;
            obj->ppos=p2;
            
            int m1 = mass; int m2 = obj->mass;
            
            vector<double> n = (p1-p2).unit();
            
            vector<double> vs1 = n*(v1.dot(n));
            vector<double> vs2 = n*(v2.dot(n));
            
            vector<double> vo1 = v1-vs1;
            vector<double> vo2 = v2-vs2;
            
            vector<double> vf1 = (vs1*(m1 - m2) + vs2*2*m2) /(m1 + m2);
            vector<double> vf2 = (vs2*(m2 - m1) + vs1*2*m1) /(m1 + m2);
            
            vel = vf1+vo1;
            obj->vel = vf2+vo2;
            
            obj->update(eTime-time);
            update(eTime-time);
            
            return 1;
        }else {
            return -1;
        }
    }else{
        return -1;
    }
}

spaceObject::~spaceObject(){
    if (sound!=NULL) {
        currentGame->openal->deleteSource(sound);
    }
}
