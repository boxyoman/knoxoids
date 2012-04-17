//
//  Shader.vsh
//  knoxoids
//
//  Created by Jonathan Covert on 4/5/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;
attribute vec2 texture;


varying lowp vec4 colorVarying;
varying vec2 vtexture;

uniform mat4 modelViewProjectionMatrix;
uniform mat4 projectionMatrix;


void main()
{
    vtexture = texture;
    
    colorVarying = color;
    
    gl_Position = modelViewProjectionMatrix * position;
}
