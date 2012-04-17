//
//  Shader.fsh
//  knoxoids
//
//  Created by Jonathan Covert on 4/5/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

precision mediump float;


varying lowp vec4 colorVarying;
varying vec2 vtexture;

uniform sampler2D uSampler;

void main()
{
    vec4 colorSample = texture2D(uSampler, vec2(vtexture.s, vtexture.t));
    gl_FragColor = colorSample*colorVarying;
}
