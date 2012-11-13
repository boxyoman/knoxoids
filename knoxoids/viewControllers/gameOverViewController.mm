//
//  gameOverViewController.m
//  knoxoids
//
//  Created by Jonathan Covert on 8/11/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import "gameOverViewController.h"

@interface gameOverViewController ()

@end

@implementation gameOverViewController
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(IBAction)restartPushed:(id)sender{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [delegate restartPushed:self];
}

-(IBAction)menuPushed:(id)sender{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [delegate menuPushed:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(NSUInteger) supportedInterfaceOrientations {
    return [self.parentViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}
@end
