//
//  gameOverViewController.h
//  knoxoids
//
//  Created by Jonathan Covert on 8/11/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol gameOverViewController <NSObject>
- (void) restartPushed: (id) sender;
- (void) menuPushed: (id) sender;
@end

@interface gameOverViewController : UIViewController{
    id<gameOverViewController> delegate;
}
@property (strong, nonatomic) id<gameOverViewController> delegate;
-(IBAction)menuPushed:(id)sender;
-(IBAction)restartPushed:(id)sender;
@end
