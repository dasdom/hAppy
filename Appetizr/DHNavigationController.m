//
//  DHNavigationController.m
//  Appetizr
//
//  Created by dasdom on 01.02.14.
//  Copyright (c) 2014 dasdom. All rights reserved.
//

#import "DHNavigationController.h"

@implementation DHNavigationController

- (BOOL)shouldAutorotate {
    return [self.visibleViewController shouldAutorotate];
}


- (NSUInteger)supportedInterfaceOrientations
{
    return [[self topViewController] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if([self.visibleViewController isMemberOfClass:NSClassFromString(@"DHWebViewController")])
    {
        return UIInterfaceOrientationPortrait;
    }
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

@end
