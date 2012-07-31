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
#include <cstdlib>
#include <ctime>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define timeToNextLevel 3

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
    
    shipObject *you;
    
    int level;
    int lives;
    int enemiesLeft;
    float finishLevelTime;
    bool levelFinished;
    int gameType;
    
    openAL *openal;
    
    void nextLevel();
    
    void changeGameType(int);
    
    void gameCleanup();
};

/*namespace game{
    void update(double);
    void setup();
    
    void youShoot();
    
    //asteroid stuff
    void addAsteroid(astObject*);
    extern astObject** asteroids;
    extern int numAst;
    //food stuff
    void addFood(foodObject*);
    void addFoods(foodObject**, int num);
    extern foodObject** foods;
    extern int numFood;
    extern foodObject *mfood;
    //Bullet stuff
    void addBullet(bulletObject*);
    extern bulletObject **bullets;
    extern int numBullets;
    
    extern shipObject *you;
    
    extern int level;
    extern int lives;
    extern int enemiesLeft;
    extern float finishLevelTime;
    extern bool levelFinished;
    extern int gameType;
    
    extern openAL *al;
    
    void nextLevel();
    
    void changeGameType(int);
    
    void gameCleanup();
};*/

@interface levelLoader : NSObject<NSXMLParserDelegate>{
    NSXMLParser *praser;
    NSError *error;
    game *currentGame;
}
- (id) initWithGame: (game*) g;
- (void) loadLevelWithStr: (NSString*) url;

@end


#endif