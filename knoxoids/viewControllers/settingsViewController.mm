//
//  settingsViewController.m
//  knoxoids
//
//  Created by Jonathan Covert on 11/14/12.
//  Copyright (c) 2012 Boxyoman. All rights reserved.
//

#import "settingsViewController.h"

@interface settingsViewController ()
-(void) timerFinished;
@end

@implementation settingsViewController

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

-(IBAction)backPushed:(id)sender{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    [delegate backSettingPushed:self];
}
-(void) timerFinished{
    actView.hidden = true;
    [actView stopAnimating];
}
-(IBAction)calibratePushed:(id)sender{
    [actView startAnimating];
    actView.hidden = false;
    
    [self performSelector:@selector(timerFinished) withObject:Nil afterDelay:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
