//
//  dataViewController.m
//  knoxoids
//
//  Created by Jonathan Covert on 4/5/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import "mainViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define pi M_PI
// Uniform index.

enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_PROJECTION_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

enum{
    CIRCLE_TEXT,
    HALO_TEXT,
    SHEILD_TEXT,
    TEXT_NUM
};

GLuint texts[TEXT_NUM];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    ATTRIB_TEXTURE,
    NUM_ATTRIBUTES
};
GLint attrib[NUM_ATTRIBUTES];

GLfloat gCubeVertexData[216] = 
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,
    
    -1.0f, 1.0f, 0.0f,
    -1.0f, -1.0f, 0.0f,
    1.0f, -1.0f, 0.0f,
    
    -1.0f, 1.0f, 0.0f,
    1.0f, 1.0f, 0.0f,
    1.0f, -1.0f, 0.0f,
};

GLfloat textureVectorData[12] = {
    1.0, 0.0,
    0.0, 0.0,
    0.0, 1.0,
    
    0.0, 1.0,
    1.0, 1.0,
    1.0, 0.0,
};
@interface mainViewController () {
    float crad;
    
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _textureBuffer;
    
    game *currentGame;
    
    CMMotionManager *motionManager;
    
    GLfloat currentColor[4];
    
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (void) drawSpaceObj: (spaceObject) obj perspective: (GLKMatrix4) projectionMatrix;
- (void) setColor_r: (float) r g: (float) g b: (float) b a: (float) a;
- (void) setColor_r: (float) r g: (float) g b: (float) b;
- (void) waitFinished: (NSTimer *) timer;
- (BOOL)loadShaders;
- (BOOL)loadTextures;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation mainViewController

@synthesize context = _context;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    
    [self setupGL];
    
    [self loadMenu];
    
    //Set up motionManager for movement
    motionManager = [[CMMotionManager alloc] init];
    
    if (motionManager.isDeviceMotionAvailable) {
        motionManager.deviceMotionUpdateInterval = 1/40;
        [motionManager startDeviceMotionUpdates];
    }
    
    //Set up game
    globals::width = view.bounds.size.width/crad;
    globals::height = view.bounds.size.height/crad;
    currentGame = new game;
    currentGame->score = score;
    currentGame->setup();
    currentGame->openal->initSound();
}
- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
    delete currentGame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}



-(NSUInteger) supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}
-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation{
    return UIDeviceOrientationLandscapeRight;
}
-(BOOL) shouldAutorotate{
    return YES;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadShaders];
    
    [self loadTextures];
    
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);
    
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    
    glGenBuffers(1, &_textureBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _textureBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(textureVectorData), textureVectorData, GL_STATIC_DRAW);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update{
    if (motionManager.deviceMotionActive) {
        //Change depending on the orientation
        int a = 1;
        if(self.interfaceOrientation == UIDeviceOrientationLandscapeLeft){
            a = -1;
        }
        //set thrusters based on angle of device
        CMAcceleration gravity = motionManager.deviceMotion.gravity;
        currentGame->you->thrust.x = a*atan2(gravity.y, -gravity.z)*200;
        currentGame->you->thrust.y = (-a*atan2(gravity.x, -gravity.z)+M_PI_4)*120;
        
    }
    
    scoreLabel.text = [@"Score: " stringByAppendingString: [[NSNumber numberWithInt:score->score] stringValue]];
    
    if (globals::gameTime == currentGame->finishLevelTime && currentGame->gameType == regularGame) {
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(waitFinished:)  userInfo:nil repeats:NO];
        levelPopup.text = [@"Level: " stringByAppendingString: [[NSNumber numberWithInt: currentGame->level+1] stringValue]];
        levelPopup.hidden = false;
    }
    
    if (currentGame->gameOver) {
        [self loadGameOver];
    }
    currentGame->update(self.timeSinceLastUpdate);

}
-(void) waitFinished: (NSTimer *) timer{
    currentGame->nextLevel();
    currentGame->levelFinished = false;
    levelPopup.hidden = true;
}
//Drawing Functions
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    
    glBindBuffer(GL_ARRAY_BUFFER, _textureBuffer);
    glEnableVertexAttribArray(attrib[ATTRIB_TEXTURE]);
    glVertexAttribPointer(attrib[ATTRIB_TEXTURE], 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    glUseProgram(_program);
    
    
    //Make projection matrix
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    
    projectionMatrix = GLKMatrix4Translate(projectionMatrix, -1.0, -1.0, 0.0f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f/(self.view.bounds.size.width/2), 1.0f/(self.view.bounds.size.height/2), 1.0f);
    projectionMatrix = GLKMatrix4Scale(projectionMatrix, crad, crad, 1);
    
    for (int i=0; i<currentGame->partSysMan->numPartSys; i++) {
        if(currentGame->partSysMan->partSystems[i]!=NULL){
            particleSystem *currentSys = currentGame->partSysMan->partSystems[i];
            for (int j=0; j<currentSys->numParts; j++) {
                if (currentSys->parts[j]->life != 0) {
                    
                    [self setColor_r:currentSys->color.r g:currentSys->color.g b:currentSys->color.b a:currentSys->parts[j]->life];
                    
                    glActiveTexture(GL_TEXTURE0);
                    glBindTexture(GL_TEXTURE_2D, texts[HALO_TEXT]);
                    glUniform1f(uniforms[UNIFORM_TEXTURE], 0);
                    
                    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(currentSys->parts[j]->pos.x, currentSys->parts[j]->pos.y, 0.0f);
                    
                    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, currentSys->parts[j]->size, currentSys->parts[j]->size, 0);
                    
                    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
                    
                    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
                    
                    glDrawArrays(GL_TRIANGLES, 0, 6);
                }
            }
        }
    }
    
    
    
    //show lives
    shipObject dummy(5, currentGame);
    float s=dummy.size();
    dummy.pos.y =s+2;
    dummy.ang = M_PI/2;
    for (int i=0; i<currentGame->lives; i++) {
        dummy.pos.x = i*(s*2+1)+s+1;
        [self setColor_r:1.0 g:1.0 b:1.0 a:0.4];
        [self drawShootingShip:dummy perspective:projectionMatrix];
    }
    
    
    //Draw you
    float a = 1.0f;
    if (currentGame->you->isInvisable) {
        float t = globals::gameTime-(currentGame->you->diedTime+youDeathTime);
        a = sin(10*t)*.5;
        a = (a<0)?-a+.2:a+.2;
    }
    
    [self setColor_r:1.0 g:1.0 b:1.0 a: a];
    [self drawShootingShip:*currentGame->you perspective:projectionMatrix];
    if (currentGame->you->sheildOn) {
        float a = 1.0f;
        //blink shield
        if(currentGame->you->sheildOnTime+11<globals::gameTime){
            
            float t = globals::gameTime-currentGame->you->sheildOnTime;
            a = sin(8*t)*.5;
            a = (a<0)?-a+.2:a+.2;
        }
        [self setColor_r:0.5 g:0.5 b:1.0 a:a];
        
        
        glBindTexture(GL_TEXTURE_2D, texts[SHEILD_TEXT]);
        GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(currentGame->you->pos.x, currentGame->you->pos.y, 0.0f);
        modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 1.1, 1.1, 1.0);
        float size = currentGame->you->size();
        modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, size*1.1, size*1.1, 1.0);
        _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
        glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
        
        glDrawArrays(GL_TRIANGLES, 0, 6);
    }
    
    
    //draw asteroids
    [self setColor_r:0.8 g:0.5 b:0.6];
    for (int i=0; i<currentGame->numAst; i++) {
        if (currentGame->asteroids[i] != NULL) {
            [self drawSpaceObj:*currentGame->asteroids[i] perspective:projectionMatrix];
        }
    }
    
    //Draw bullets
    for (int i = 0; i<currentGame->numBullets; i++) {
        if (currentGame->bullets[i] != NULL) {
            if (currentGame->bullets[i]->target!=NULL) {
                [self setColor_r:1.0 g:0.16 b:0.47];
            }else{
                [self setColor_r:0.64 g:0.16 b:0.47];
            }
            [self drawSpaceObj:*currentGame->bullets[i] perspective:projectionMatrix];
        }
    }
    
    //Draw food
    [self setColor_r:0.6 g:0.6 b:0.6];
    [self drawSpaceObj:*currentGame->mfood perspective:projectionMatrix];
    for (int i=0; i<currentGame->numFood; i++) {
        if (currentGame->foods[i] != NULL) {
            if(currentGame->foods[i]->bornTime+2*foodLife/3 < globals::gameTime && currentGame->foods[i]->shouldBeRemoved){
                float a = 1-(globals::gameTime - (currentGame->foods[i]->bornTime+2*foodLife/3))/(foodLife/3);
                [self setColor_r:0.6 g:0.6 b:0.6 a: a];
            }else{
                if (currentGame->foods[i]->type == lifeFood) {
                    [self setColor_r:0.0 g:1.0 b:0.0];
                }else if (currentGame->foods[i]->type == sheildFood){
                    [self setColor_r:0.5 g:0.5 b:1.0];
                }else{
                    [self setColor_r:0.6 g:0.6 b:0.6];
                }
            }
            [self drawSpaceObj:*currentGame->foods[i] perspective:projectionMatrix];
        }
    }
    
    
    //draw ships
    for (int i=0; i<currentGame->numShips; i++) {
        if (currentGame->ships[i] != NULL && currentGame->ships[i]->remove==0) {
            switch (currentGame->ships[i]->type) {
                case alienShip:
                    [self setColor_r:1.0 g:0.46 b:0.46];
                    break;
                case regularTurret:
                    [self setColor_r:1.0 g:0.0 b:0.0];
                    break;
                case guidedTurret:
                    [self setColor_r:1.0 g:0.0 b:0.0];
                    break;
                default:
                    break;
            }
            [self drawShootingShip:*currentGame->ships[i] perspective:projectionMatrix];
        }
    }
    
}

- (void) drawSpaceObj: (spaceObject) obj perspective: (GLKMatrix4) projectionMatrix{
    if (obj.remove == 0) {
        float s = obj.size();
        if (obj.mass > 1) {
            float ang = M_PI*2/(float)obj.mass;
            for (int i=0; i<obj.mass; i++) {
                [self drawCircle_x:obj.pos.x+cos(i*ang)*(s-1) y:obj.pos.y+sin(i*ang)*(s-1) perspective:projectionMatrix];
            }
        }else if(obj.mass == 1){
            [self drawCircle_x:obj.pos.x y:obj.pos.y perspective:projectionMatrix];
        }
    }
}

- (void) setColor_r: (float) r g: (float) g b: (float) b {
    GLfloat color[4] = {r, g, b, 1.0};
    glVertexAttrib4fv(attrib[ATTRIB_COLOR], color);
    
    currentColor[0] = color[0];
    currentColor[1] = color[1];
    currentColor[2] = color[2];
    currentColor[3] = color[3];
}

- (void) setColor_r: (float) r g: (float) g b: (float) b a: (float) a {
    GLfloat color[4] = {r, g, b, a};
    glVertexAttrib4fv(attrib[ATTRIB_COLOR], color);
    
    currentColor[0] = color[0];
    currentColor[1] = color[1];
    currentColor[2] = color[2];
    currentColor[3] = color[3];
}
- (void) drawCircle_x:(float) x y:(float) y perspective: (GLKMatrix4) projectionMatrix
{   
    //glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texts[CIRCLE_TEXT]);
    glUniform1f(uniforms[UNIFORM_TEXTURE], 0);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(x, y, 0.0f);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 1.1, 1.1, 1.0);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}
- (void) drawShootingShip: (shipObject) obj perspective: (GLKMatrix4) projectionMatrix {
    if (obj.remove == 0) {
        float s = obj.size();
        
        float shipColor[4] = {currentColor[0],currentColor[1],currentColor[2], currentColor[3]};
        
        if (obj.type == guidedTurret) { [self setColor_r:1.0 g:0.16 b:0.47]; }else{ [self setColor_r:0.64 g:0.16 b:0.47]; }
        
        if ((obj.type == regularTurret || obj.type == guidedTurret) && obj.gunOn == 0) {
            float dist = (globals::gameTime-obj.shootTime)/4*(s+1);
            [self drawCircle_x:obj.pos.x+(dist)*cos(obj.ang) y:obj.pos.y+(dist)*sin(obj.ang) perspective:projectionMatrix];
        }
        
        [self setColor_r:shipColor[0] g:shipColor[1] b:shipColor[2] a:shipColor[3]];
        
        float ang = M_PI*2/(float)obj.mass;
        for (int i=0; i<obj.mass; i++) {
            [self drawCircle_x:obj.pos.x+cos(i*ang+obj.ang)*(s-1) y:obj.pos.y+sin(i*ang+obj.ang)*(s-1) perspective:projectionMatrix];
        }
        if (obj.type == guidedTurret) { [self setColor_r:1.0 g:0.16 b:0.47]; }else{ [self setColor_r:0.64 g:0.16 b:0.47]; }
        
        if(obj.mass>=3 && obj.gunOn == 1){
            [self drawCircle_x:obj.pos.x+(s+1)*cos(obj.ang) y:obj.pos.y+(s+1)*sin(obj.ang) perspective:projectionMatrix];
        }
    }
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGRect bounds = self.view.bounds;
    UITouch* touch = [touches anyObject];
    if ([touches count] == 1 && self.paused != true) {
        if ([touch view] == self.view) {
            CGPoint l = [touch locationInView:self.view];
            currentGame->you->ang = atan2((bounds.size.height - l.y)/crad-currentGame->you->pos.y,  l.x/crad-currentGame->you->pos.x);
           
        }
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGRect bounds = self.view.bounds;
    UITouch* touch = [touches anyObject];
    if ([touches count] == 1 && self.paused != true) {
        if ([touch view] == self.view) {
            CGPoint l = [touch locationInView:self.view];
            
            currentGame->you->ang = atan2((bounds.size.height - l.y)/crad-currentGame->you->pos.y,  l.x/crad-currentGame->you->pos.x);
            
        }
    }
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    CGRect bounds = self.view.bounds;
    UITouch* touch = [touches anyObject];
    if ([touches count] == 1 && self.paused != true) {
        if ([touch view] == self.view) {
            CGPoint l = [touch locationInView:self.view];
            currentGame->you->ang = atan2((bounds.size.height - l.y)/crad-currentGame->you->pos.y,  l.x/crad-currentGame->you->pos.x);
            currentGame->youShoot();
        }
    }
}
- (IBAction)twoFingersTwoTaps:(UIGestureRecognizer *)sender{
    [self pauseGame];
}

- (void) pauseGame{
    self.paused = true;
    
    NSString *openingNib;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        openingNib = @"pausedViewControlleriPad";
    }else{
        openingNib = @"pausedViewController";
    }
    
    pausedViewController *paused = [[pausedViewController alloc] initWithNibName:openingNib bundle:nil];
    paused.delegate = (id<pausedViewController>)self;
    [self addChildViewController:paused];
    [self.view addSubview:paused.view];
}
- (void) loadMenu{
    NSString *openingNib;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        crad = 8.0;
        openingNib = @"openingViewControlleriPad";
    }else{
        crad = 4.0;
        openingNib = @"openingViewController";
    }
    
    openingViewController *opening = [[openingViewController alloc] initWithNibName:openingNib bundle:nil];
    opening.delegate = (id<openingViewController>)self;
    [self addChildViewController:opening];
    [self.view addSubview:opening.view];
}
- (void) loadGameOver{
    NSString *openingNib;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        openingNib = @"gameOverViewControlleriPad";
    }else{
        openingNib = @"gameOverViewController";
    }
    
    gameOverViewController *gameover = [[gameOverViewController alloc] initWithNibName:openingNib bundle:nil];
    gameover.delegate = (id<gameOverViewController>)self;
    [self addChildViewController:gameover];
    [self.view addSubview:gameover.view];
    
    self.paused = true;
}
- (void) setScoreTracker:(scoreTracker *)s{
    score = s;
}
- (void) playPushed: (id) sender{
    currentGame->changeGameType(regularGame);
}
- (void) menuPushed: (id) sender{
    currentGame->changeGameType(background);
    self.paused = false;
    [self loadMenu];
}
- (void) resumePushed:(id)sender{
    self.paused = false;
}
- (void) restartPushed:(id)sender{
    self.paused = false;
    currentGame->changeGameType(regularGame);
}
//Loading OpenGL functions
- (BOOL)loadTextures{
    CGImageRef image;
    CGContextRef imageContext;
    GLubyte *textData;
    int width;
    int height;
    
    image = [UIImage imageNamed:@"ball.png"].CGImage;
    width = (int)CGImageGetWidth(image);
    height = (int)CGImageGetHeight(image);
    
    if (image) {
        textData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
        imageContext = CGBitmapContextCreate(textData, width, height, 8, width*4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
        CGContextClearRect( imageContext, CGRectMake( 0, 0, width, height ) );
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
        
        CGContextRelease(imageContext);
        
        glGenTextures(TEXT_NUM, texts);
        glBindTexture(GL_TEXTURE_2D, texts[CIRCLE_TEXT]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textData);
        glEnable(GL_TEXTURE_2D);
        
        
        free(textData);
    }else{
        return NO;
    }
    
    image = [UIImage imageNamed:@"halo2.png"].CGImage;
    width = (int)CGImageGetWidth(image);
    height = (int)CGImageGetHeight(image);
    
    if (image) {
        textData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
        imageContext = CGBitmapContextCreate(textData, width, height, 8, width*4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
        CGContextClearRect( imageContext, CGRectMake( 0, 0, width, height ) );
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
        
        CGContextRelease(imageContext);
        
        glBindTexture(GL_TEXTURE_2D, texts[HALO_TEXT]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textData);
        glEnable(GL_TEXTURE_2D);
        
        
        free(textData);
    }else{
        printf("\n\nfailed to load image\n");
        return NO;
    }
    
    image = [UIImage imageNamed:@"sheild.png"].CGImage;
    width = (int)CGImageGetWidth(image);
    height = (int)CGImageGetHeight(image);
    
    if (image) {
        textData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
        imageContext = CGBitmapContextCreate(textData, width, height, 8, width*4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
        CGContextClearRect( imageContext, CGRectMake( 0, 0, width, height ) );
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
        
        CGContextRelease(imageContext);
        
        glBindTexture(GL_TEXTURE_2D, texts[SHEILD_TEXT]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textData);
        glEnable(GL_TEXTURE_2D);
        
        
        free(textData);
    }else{
        return NO;
    }
    
    return YES;
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, ATTRIB_VERTEX, "position");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    //Get Attribute locations
    attrib[ATTRIB_COLOR] = glGetAttribLocation(_program, "color");
    attrib[ATTRIB_TEXTURE] = glGetAttribLocation(_program, "texture");
    
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_PROJECTION_MATRIX] = glGetUniformLocation(_program, "projectionMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(_program, "uSampler");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end