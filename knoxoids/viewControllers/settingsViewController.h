//
//  settingsViewController.h
//  knoxoids
//
//  Created by Jonathan Covert on 11/14/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol settingsProtocal <NSObject>
-(void)backSettingPushed: (id)sender;
@end

@interface settingsViewController : UIViewController{
    id<settingsProtocal> delegate;
    IBOutlet UIButton *backButton;
    IBOutlet UIActivityIndicatorView *actView;
}
@property (strong, nonatomic) id<settingsProtocal> delegate;

-(IBAction) backPushed:(id) sender;
-(IBAction)calibratePushed:(id)sender;

@end
