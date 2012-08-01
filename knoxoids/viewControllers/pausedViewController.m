//
//  pausedViewController.m
//  knoxoids
//
//  Created by Jonathan Covert on 7/31/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import "pausedViewController.h"

@interface pausedViewController ()

@end

@implementation pausedViewController
@synthesize delegate = delegate;
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

- (IBAction)restartPushed:(id)sender{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [delegate restartPushed:self];
}

- (IBAction)resumePushed:(id)sender{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [delegate resumePushed:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
