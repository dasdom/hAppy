//
//  UIApplication+Storyboard.m
//  Appetizr
//
//  Created by dasdom on 09.02.14.
//  Copyright (c) 2014 dasdom. All rights reserved.
//

#import "UIApplication+Storyboard.h"

@implementation UIApplication (Storyboard)

+ (UIStoryboard*)mainStoryboard {
    return [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
}

+ (UIStoryboard*)settingsStoryboard {
    return [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
}

@end
