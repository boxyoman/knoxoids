//
//  pausedViewController.h
//  knoxoids
//
//  Created by Jonathan Covert on 7/31/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol pausedViewController <NSObject>
- (void) resumePushed: (id) sender;
- (void) restartPushed: (id) sender;
- (void) menuPushed: (id) sender;
@end

@interface pausedViewController : UIViewController{
    IBOutlet UIButton *resume;
    IBOutlet UIButton *restart;
    IBOutlet UIButton *menu;
    id<pausedViewController> delegate;
}
@property (strong, nonatomic) id<pausedViewController> delegate;
- (IBAction)resumePushed:(id)sender;
- (IBAction)restartPushed:(id)sender;
- (IBAction)menuPushed:(id)sender;
@end
