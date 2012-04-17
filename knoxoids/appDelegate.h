//
//  dataAppDelegate.h
//  knoxoids
//
//  Created by Jonathan Covert on 4/5/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import <UIKit/UIKit.h>

@class mainViewController;

@interface appDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) mainViewController *viewController;

@end
