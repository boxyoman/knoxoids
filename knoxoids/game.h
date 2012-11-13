#ifndef knoxoids_game_h
#define knoxoids_game_h

#include "vector.h"
#include "spaceObject.h"
#include "shipObject.h"
#include "gameGlobals.h"
#include "bulletObject.h"
#include "foodObject.h"
#include "asteroidObject.h"
#include "openal.h"
#include "sound.h"
#include "scoreTracker.h"
#include "particleSystemManager.h"
#include <cstdlib>
#include <ctime>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define youDeathTime 5

enum gameType{
    regularGame=0,
    background,
    lvlBlvl
};

class game {
public:
    game();
    
    void update(double);
    void setup();
    
    void youShoot();
    
    //asteroid stuff
    void addAsteroid(astObject*);
    astObject** asteroids;
    int numAst;
    //food stuff
    void addFood(foodObject*);
    void addFoods(foodObject**, int num);
    foodObject** foods;
    int numFood;
    foodObject *mfood;
    //Bullet stuff
    void addBullet(bulletObject*);
    bulletObject **bullets;
    int numBullets;
    //alien and ship stuff
    void addShip(shipObject*);
    shipObject **ships;
    int numShips;
    
    
    shipObject *you;
    
    int level;
    int lives;
    bool gameOver;
    int enemiesLeft;
    float finishLevelTime;
    bool levelFinished;
    int gameType;
    
    scoreTracker *score;
    openAL *openal;
    particleSysManager *partSysMan;
    
    void nextLevel();
    
    void changeGameType(int);
    
    ~game();
private:
    void gameCleanup();
};

@interface levelLoader : NSObject<NSXMLParserDelegate>{
    NSXMLParser *praser;
    NSError *error;
    game *currentGame;
}
- (id) initWithGame: (game*) g;
- (bool) loadLevelWithStr: (NSString*) url;

@end


#endif