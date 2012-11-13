//
//  openingViewController.m
//  knoxoids
//
//  Created by Jonathan Covert on 4/6/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import "openingViewController.h"

@interface openingViewController ()

@end

@implementation openingViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(IBAction)playPushed:(id)sender{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [delegate playPushed: self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
