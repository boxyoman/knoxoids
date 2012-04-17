//
//  dataViewController.m
//  knoxoids
//
//  Created by Jonathan Covert on 4/5/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import "mainViewController.h"
#include "game.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define pi 3.1415
// Uniform index.

int crad = 4;

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
    GLuint _program;
    
    GLKMatrix4 _modelViewProjectionMatrix;
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    GLuint _textureBuffer;
    game *game;
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (void) setColor_r: (float) r g: (float) g b: (float) b a: (float) a;
- (void) setColor_r: (float) r g: (float) g b: (float) b;

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
    NSString *openingNib;
    //check if it is an iPad and change crad if it is an iPad
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        crad *= 2;
        openingNib = @"openingViewControlleriPad";
    }else{
        openingNib = @"openingViewController";
    }
    
    openingViewController *opening = [[openingViewController alloc] initWithNibName:openingNib bundle:nil];
    opening.delegate = (id<openingViewController>)self;
    [self addChildViewController:opening];
    [self.view addSubview:opening.view];
    
    //Set up game
    self->game = makeNewGame(self.view.bounds.size.width, self.view.bounds.size.height, crad, background);
    
}

- (void)viewDidUnload
{    
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
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
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, BUFFER_OFFSET(0));
    
    glBindVertexArrayOES(0);
    
    glGenBuffers(1, &_textureBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _textureBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(textureVectorData), textureVectorData, GL_STATIC_DRAW);
    
    glVertexAttribPointer(attrib[ATTRIB_TEXTURE], 2, GL_FLOAT, GL_FALSE, 0, 0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    update(self->game, self.timeSinceLastUpdate);
}
//Drawing Functions
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    if (game != NULL) {
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glBindBuffer(GL_ARRAY_BUFFER, _textureBuffer);
        glEnableVertexAttribArray(attrib[ATTRIB_TEXTURE]);
        glVertexAttribPointer(attrib[ATTRIB_TEXTURE], 2, GL_FLOAT, GL_FALSE, 0, 0);
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
        
        glBindVertexArrayOES(_vertexArray);
        
        // Render the object again with ES2
        glUseProgram(_program);
        
        GLKMatrix4 projectionMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
        
        projectionMatrix = GLKMatrix4Translate(projectionMatrix, -1.0, -1.0, 0.0f);
        projectionMatrix = GLKMatrix4Scale(projectionMatrix, 1.0f/(self.view.bounds.size.width/2), 1.0f/(self.view.bounds.size.height/2), 1.0f);
        projectionMatrix = GLKMatrix4Translate(projectionMatrix, 1.0, 1.0, 0);
        
        //Draw you
        [self setColor_r:1 g:1 b:1];
        [self drawShootingShipX:self->game->you.p[x] Y:self->game->you.p[y] m:self->game->you.m angle:self->game->you.ang gunOn:self->game->you.gunOn perspective:projectionMatrix];
        
        glDrawArrays(GL_TRIANGLES, 0, 6);
        
        //Draw mFood
        [self setColor_r:0.6 g:0.6 b:0.6];
        [self drawCircle_x:game->mFood->p[x] y:game->mFood->p[y] perspective: projectionMatrix];
        
        //Draw Food
        for (int i = 0; i < 30; i++) {
            if (game->food->p[x][i] != 0) {
                [self setColor_r:0.6 g:0.6 b:0.6];
                [self drawCircle_x:game->food->p[x][i] y:game->food->p[y][i] perspective: projectionMatrix];
            }
        }
        
        //Draw Bullets
        for (int i = 0; i < 30; i++) {
            if (game->bullet->p[x][i] != 0) {
                [self setColor_r:0.64 g:0.16 b:0.47];
                [self drawCircle_x:game->bullet->p[x][i] y:game->bullet->p[y][i] perspective: projectionMatrix];
            }
        }
        //Draw ateroids
        for (int i = 0; i < 20; i++) {
            if (game->asteroids->p[x][i] != 0) {
                [self setColor_r:1.0 g:0.4 b:0.5];
                for(double counter = 0; counter<2*pi; counter=counter+2*pi/game->asteroids->m[i]) {
                    [self drawCircle_x:game->asteroids->p[x][i]+(size(game, game->asteroids->m[i])-game->crad)*sin(counter) y:game->asteroids->p[y][i]+(size(game, game->asteroids->m[i])-crad)*cos(counter) perspective:projectionMatrix];
                }
            }
        }
    }
}

- (void) setColor_r: (float) r g: (float) g b: (float) b {
    GLfloat color[4] = {r, g, b, 1.0};
    glVertexAttrib4fv(attrib[ATTRIB_COLOR], color);
}

- (void) setColor_r: (float) r g: (float) g b: (float) b a: (float) a {
    GLfloat color[4] = {r, g, b, a};
    glVertexAttrib4fv(attrib[ATTRIB_COLOR], color);
}
- (void) drawCircle_x:(float) x y:(float) y perspective: (GLKMatrix4) projectionMatrix
{   
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texts[CIRCLE_TEXT]);
    glUniform1f(uniforms[UNIFORM_TEXTURE], 0);
    
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(x, y, 0.0f);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, crad, crad, 0);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, 1.1, 1.1, 0);
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}
- (void) drawShootingShipX: (int) x Y: (int) y m: (int) m angle:(float) ang gunOn: (int) gunOn perspective: (GLKMatrix4) projectionMatrix {

    float counter;
    
    for(counter = ang; counter<2*pi+ang; counter=counter+2*pi/(m)) {
        [self drawCircle_x: x+(size(game, m)-crad)*cos(counter) y:y+(size(game, m)-crad)*sin(counter) perspective: projectionMatrix];
    }
    [self setColor_r:0.64 g:0.16 b:0.47];
    [self drawCircle_x:x+(size(game, m)-crad)*cos(ang) y:y+(size(game, m)-crad)*sin(ang) perspective:projectionMatrix];
    
    if(m>=3 && gunOn == 1){
        [self drawCircle_x:x+(crad+size(game, m))*cos(ang) y:y+(crad+size(game, m))*sin(ang) perspective:projectionMatrix];
    }
    if(m>5){
        [self drawCircle_x:x+(-3*crad+size(game, m))*cos(ang) y:y+(-3*crad+size(game, m))*sin(ang) perspective:projectionMatrix];
    }
}
//
- (void) playPushed: (id) sender{
    changeGameTypeTo(game, survival);
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGRect bounds = self.view.bounds;
    UITouch* touch = [touches anyObject];
    if ([touch view] == self.view) {
        CGPoint l = [touch locationInView:self.view];
        self->game->you.ang = atan2l(bounds.size.height - l.y-self->game->you.p[y], l.x-self->game->you.p[x]);
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    CGRect bounds = self.view.bounds;
    UITouch* touch = [touches anyObject];
    if ([touch view] == self.view) {
        CGPoint l = [touch locationInView:self.view];
        self->game->you.ang = atan2l(bounds.size.height - l.y-self->game->you.p[y], l.x-self->game->you.p[x]);
    }
}
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch* touch = [touches anyObject];
    if ([touch view] == self.view) {
        shoot(game, game->you.p, game->you.v, &game->you.m, &game->you.ang, &game->you.gunOn);
    }
}

//Loading OpenGL functions
- (BOOL)loadTextures{
    CGImageRef image;
    CGContextRef imageContext;
    GLubyte *textData;
    int width;
    int height;
    
    image = [UIImage imageNamed:@"ball.png"].CGImage;
    width = CGImageGetWidth(image);
    height = CGImageGetHeight(image);
    
    if (image) {
        textData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
        imageContext = CGBitmapContextCreate(textData, width, height, 8, width*4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
        CGContextClearRect( imageContext, CGRectMake( 0, 0, width, height ) );
        CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
        
        CGContextRelease(imageContext);
        
        glGenTextures(TEXT_NUM, texts);
        glBindTexture(GL_TEXTURE_2D, texts[CIRCLE_TEXT]);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textData);
        glEnable(GL_TEXTURE_2D);
        
        
        free(textData);
    }else{
        return NO;
    }
    
    image = [UIImage imageNamed:@"0001.png"].CGImage;
    width = CGImageGetWidth(image);
    height = CGImageGetHeight(image);
    
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
        return NO;
    }
    
    image = [UIImage imageNamed:@"sheild.png"].CGImage;
    width = CGImageGetWidth(image);
    height = CGImageGetHeight(image);
    
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
