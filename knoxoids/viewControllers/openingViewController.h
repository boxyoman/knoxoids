//
//  openingViewController.h
//  knoxoids
//
//  Created by Jonathan Covert on 4/6/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "settingsViewController.h"
@protocol openingViewController <NSObject>
- (void) playPushed: (id) sender;
@end

@interface openingViewController : UIViewController<settingsProtocal>{
    id<openingViewController> delegate;
}
@property (strong, nonatomic) id<openingViewController> delegate;
-(void)backSettingPushed: (id)sender;
-(IBAction)playPushed:(id)sender;
-(IBAction)settingsPushed:(id) sender;
@end
