//
//  openingViewController.h
//  knoxoids
//
//  Created by Jonathan Covert on 4/6/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol openingViewController <NSObject>
- (void) playPushed: (id) sender;
@end

@interface openingViewController : UIViewController{
    id<openingViewController> delegate;
}
@property (strong, nonatomic) id<openingViewController> delegate;
-(IBAction)playPushed:(id)sender;
@end
