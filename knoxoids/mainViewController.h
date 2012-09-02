//
//  dataViewController.h
//  knoxoids
//
//  Created by Jonathan Covert on 4/5/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <CoreMotion/CMError.h>
#import <CoreMotion/CMErrorDomain.h>
#import <CoreMotion/CMMotionManager.h>
#import "pausedViewController.h"
#import "openingViewController.h"
#import "gameOverViewController.h"
#include "game.h"
#include "gameGlobals.h"

@interface mainViewController : GLKViewController<openingViewController, pausedViewController>{
    IBOutlet UILabel *levelPopup;
}
- (IBAction)twoFingersTwoTaps:(UIGestureRecognizer *)sender;
@end
