//
//  DHSecondViewController.m
//  Appetizr
//
//  Created by dasdom on 12.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHSecondViewController.h"

@interface DHSecondViewController ()

@end

@implementation DHSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
