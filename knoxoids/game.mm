#include "game.h"
#include <stdio.h>
#include <stdlib.h>
/*using namespace game;

shipObject *game::you = NULL;

bulletObject **game::bullets;
int game::numBullets = 5;

foodObject **game::foods;
int game::numFood = 15;

astObject **game::asteroids;
int game::numAst = 4;

int game::lives = 2;
int game::level = 0;
float game::finishLevelTime=0;
int game::gameType=background;
bool game::levelFinished = false;
foodObject *game::mfood = NULL;

openAL *game::al= new openAL;

int game::enemiesLeft=0;*/

vector<double> getRandomPos(){
    return vector<double>(rand()/(float)RAND_MAX*globals::width,rand()/(float)RAND_MAX*globals::height);
}

game::game(){
    numBullets = 5;
    numFood = 15;
    numAst = 4;
    lives = 2;
    level = 0;
    finishLevelTime=0;
    gameType=background;
    levelFinished = false;
    mfood = NULL;
    openal= new openAL();
}

void game::setup(){
    srand(time(NULL));
    
    //setup bullets
    bullets = (bulletObject**)malloc(sizeof(bulletObject**)*numBullets);
    for (int i=0; i<numBullets; i++) {
        bullets[i] = NULL;
    }
    //setup food
    foods = (foodObject**)malloc(sizeof(foodObject**)*numFood);
    for (int i=0; i<numFood; i++) {
        foods[i] = NULL;
    }
    
    //setup asteroids
    asteroids = (astObject**)malloc(sizeof(astObject**)*numAst);
    for (int i=0; i<numAst; i++) {
        asteroids[i] = NULL;
    }
    
    //
    mfood = new foodObject(getRandomPos(), this);
    mfood->shouldBeRemoved=false;
    
    you = new shipObject(5, this);
    //Put you in the middle
    you->pos = vector<double>(globals::width/2, globals::height/2);
    you->vel = you->vel*0;
    you->thrust = you->thrust*0;
    you->gunOn = 1;
    
    openal->listener = you;
    
    globals::gameTime=0;
    
    if (gameType != background) {
        openal->playSouds = true;
    }
}


void game::update(double eTime){
    //Update the game time;
    globals::gameTime += eTime;
    
    openal->update();
    
    if (gameType == background) {
        vector<double> diff = mfood->pos-you->pos;
        you->thrust = diff.unit()*20;
        if (asteroids[0]!=NULL) {
            you->ang = (you->pos).angle(asteroids[0]->pos);
        }
    }
    //Update you
    you->update(eTime);

    if (you->remove == 0) {
        if (you->collision(mfood, eTime) == 1) {
            you->ate();
            mfood->pos = getRandomPos();
            mfood->vel = vector<double>(0,0);
            if (gameType == background) {
                youShoot();
            }
        }
    }
    
    mfood->update(eTime);
    
    enemiesLeft=0;
    
    //Update bullets
    for (int i=0; i<numBullets; i++) {
        if (bullets[i] != NULL) {
            //used to determine if the bullet has been destoried
            bool notDead = true;
            //Delete bullet, if needed, then move on to the next bullet
            if (bullets[i]->remove) {
                delete bullets[i];
                bullets[i] = NULL;
                continue;
            }
            bullets[i]->update(eTime);
            
            //check for bullet-bullet collision
            for (int j=i+1; j<game::numBullets && notDead; j++) {
                if (bullets[j] != NULL && bullets[j]->remove==0) {
                    bullets[i]->collision(bullets[j], eTime);
                }
            }
            //Check for bullet-asteroid collision
            for (int j=0; j<numAst && notDead; j++) {
                if(asteroids[j] != NULL && asteroids[j]->remove==0){
                    //If collision make asteroid blowup
                    if (bullets[i]->collision(asteroids[j], eTime) == 1) {
                        if (asteroids[j]->mass > 5) {
                            addAsteroid(asteroids[j]->splitAsteroid((bullets[i]->pos).angle(asteroids[j]->pos)));
                            bullets[i]->remove = 1;
                            notDead = false;
                            break;
                        }else{
                            addFoods(asteroids[j]->destroy(), asteroids[j]->mass);
                            asteroids[j]->remove = 1;
                            bullets[i]->remove = 1;
                            notDead = false;
                            break;
                        }
                    }
                }
            }
            //Check for bullet-food collision
            for (int j=0; j<numFood && notDead; j++) {
                if (foods[j]!=NULL && foods[j]->remove==0) {
                    bullets[i]->collision(foods[j], eTime);
                }
            }
            //check for bullet-mfood collision
            bullets[i]->collision(mfood, eTime);
        }
    }
    
    //Update asteroids
    for (int i=0; i<numAst; i++) {
        if (asteroids[i] != NULL) {
            //Delete asteroid, if needed, then move on to the next asteroid
            if (asteroids[i]->remove == 1) {
                delete asteroids[i];
                asteroids[i] = NULL;
                continue;
            }
            
            enemiesLeft++;
            
            asteroids[i]->update(eTime);
            if (you->remove==0) {
                if (you->collision(asteroids[i], eTime)==1) {
                    if (gameType != background) {
                        addFoods(you->destroy(), you->mass);
                        you->remove=1;
                    }
                }
            }
            mfood->collision(asteroids[i], eTime);
            
            //check for asteroid-asteroid collision
            for (int j=i+1; j<numAst; j++) {
                if (asteroids[j]!=NULL && asteroids[j]->remove==0) {
                    asteroids[i]->collision(asteroids[j], eTime);
                }
            }
            //check for ateroid-food collision
            for (int j=0; j<numFood; j++) {
                if (foods[j]!=NULL && foods[j]->remove==0) {
                    asteroids[i]->collision(foods[j], eTime);
                }
            }
        }
    }
    
    //Update food
    for (int i=0; i<numFood; i++) {
        if (foods[i] != NULL) {
            //Delete food, if needed, then move on to the next food
            if (foods[i]->remove == 1) {
                delete foods[i];
                foods[i] = NULL;
                continue;
                
            }
            foods[i]->update(eTime);
            
            //See if collision with you, if so add to your mass and remove food
            if (you->remove == 0) {
                if (foods[i]->collision(you, eTime)==1) {
                    you->ate();
                    foods[i]->remove=1;
                    if (gameType == background) {
                        youShoot();
                    }
                    continue;
                }
            }
            //Check for food-food colision
            for (int j=i+1; j<numFood; j++) {
                if (foods[j] != NULL && foods[j]->remove==0) {
                    foods[i]->collision(foods[j], eTime);
                }
            }
        }
    }
    if (gameType == background && enemiesLeft==0) {
        asteroids[0] = new astObject(5, this);
        do{
            asteroids[0]->pos.x = rand()/(float)RAND_MAX*globals::width;
            asteroids[0]->pos.y = rand()/(float)RAND_MAX*globals::height;
        }while ((asteroids[0]->pos-you->pos).mag2() < (you->size()+asteroids[0]->size())*(you->size()+asteroids[0]->size()));
        vector<double> diff = asteroids[0]->pos - you->pos;
        asteroids[0]->vel = diff.unit() * 20;
    }else if(enemiesLeft==0 && levelFinished == false){
        finishLevelTime = globals::gameTime;
        levelFinished = true;
    }
}
void game::youShoot(){
    if (you->remove ==0) {
        bulletObject *bullet;
        bullet = you->shoot();
        addBullet(bullet);

    }
}

void game::changeGameType(int gt){
    gameType = gt;
    gameCleanup();
    setup();
}

void game::gameCleanup(){
    //Cleanup all remaining bullets
    for (int i=0; i<numBullets; i++) {
        if (bullets[i] != NULL) {
            delete bullets[i];
            bullets[i] = NULL;
        }
    }
    free(bullets);
    
    //Cleanup all remaining asteroids
    for (int i=0; i<numAst; i++) {
        if (asteroids[i] != NULL) {
            delete asteroids[i];
            asteroids[i] = NULL;
        }
    }
    free(asteroids);
    
    //Cleanup all remaining food
    for (int i=0; i<numFood; i++) {
        if (foods[i] != NULL) {
            delete foods[i];
            foods[i] = NULL;
        }
    }
    free(foods);
    
    delete you;
    delete mfood;
    //Game over
}

//Adding objects functions

void game::addAsteroid(astObject* asteroid){
    if (asteroid != NULL) {
        int i = 0;
        for (;i<=numAst; i++) {
            if (i==numAst) {
                break;
            }else {
                if (asteroids[i] == NULL) {
                    break;
                }
            }
        }
        //See if you need to make more space
        if (i < numAst) {
            asteroids[i] = asteroid;
        }else {
            //make more space
            asteroids = (astObject**)realloc(asteroids, sizeof(astObject**)*(i+1));
            asteroids[i] = asteroid;
            numAst ++;
        }
    }
}

//call when an object is destoried and returns food objects
void game::addFoods(foodObject** food, int num){
    for (int i=0; i<num; i++) {
        addFood(food[i]);
    }
    free(food);
}
void game::addFood(foodObject* food){
    if (food != NULL) {
        int i = 0;
        for (;i<=numFood; i++) {
            if (i==numFood) {
                break;
            }else {
                if (foods[i] == NULL) {
                    break;
                }
            }
        }
        
        if (i < numFood) {
            foods[i] = food;
        }else {
            foods = (foodObject**)realloc(foods, sizeof(foodObject**)*(i+1));
            foods[i] = food;
            numFood ++;
        }
    }
}

void game::addBullet(bulletObject* bullet){
    if (bullet != NULL) {
        int i = 0;
        for (;i<=numBullets; i++) {
            if (i==numBullets) {
                break;
            }else {
                if (bullets[i] == NULL) {
                    break;
                }
            }
        }
        
        if (i < numBullets) {
            bullets[i] = bullet;
        }else {
            bullets = (bulletObject**)realloc(bullets, sizeof(bulletObject**)*(i+1));
            bullets[i] = bullet;
            numBullets ++;
        }
    }
}

void game::nextLevel(){
    level++;
    
    //Get filename
    NSString* str = [@"level" stringByAppendingString: [[NSNumber numberWithInt:level] stringValue]];
    
    
    levelLoader *loader = [[levelLoader alloc] initWithGame: this];
    [loader loadLevelWithStr: str];
}

@implementation levelLoader

- (id) initWithGame:(game *)g{
    self = [super init];
    if (self) {
        currentGame = g;
    }
    return self;
}

- (id) init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) loadLevelWithStr: (NSString *) url{
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *test = [bundle pathForResource: url ofType:@"xml"];
    if(test != nil){
        NSURL *fileUrl = [NSURL fileURLWithPath:test];
        praser = [[NSXMLParser alloc] initWithContentsOfURL:fileUrl];
        [praser setDelegate:self];
        [praser setShouldProcessNamespaces:NO];
        [praser setShouldReportNamespacePrefixes:NO];
        [praser setShouldResolveExternalEntities:NO];
        [praser parse];
        
        error = [praser parserError];
        
        if (error) {
            // NSLog([error localizedDescription]);
            printf("xml praser error:(\n");
        }
    }else{
        printf("File not found\n");
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    if(currentGame->gameType == lvlBlvl && [elementName isEqualToString:@"level"]){
        currentGame->lives = [[attributeDict valueForKey:@"lives"] intValue];
    }
    
    if ([elementName isEqualToString:@"object"]) {
        if ([[attributeDict valueForKey:@"id"] isEqualToString:@"asteroid"]) {
            astObject *ast = new astObject(currentGame);
            
            ast->pos.x = [[attributeDict valueForKey:@"px"] floatValue];
            ast->pos.y = [[attributeDict valueForKey:@"py"] floatValue];
            if(ast->pos.mag2() == 0){
                do{
                    ast->pos = getRandomPos();
                }while ((ast->pos - currentGame->you->pos).mag2() < (currentGame->you->size()+ast->size())*(currentGame->you->size()+ast->size()));
            }
            //Make sure asteroid starts moving away from the guy
            vector<double> diff = ast->pos - currentGame->you->pos;
            ast->vel = diff.unit() * 20;
            
            ast->mass = [[attributeDict valueForKey:@"m"] integerValue];
            currentGame->addAsteroid(ast);
        }
    }
    
}

-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
	NSLog(@"Error on XML Parse: %@", [parseError localizedDescription] );
}

@end
