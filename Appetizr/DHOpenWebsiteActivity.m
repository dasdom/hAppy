//
//  DHOpenWebsiteActivity.m
//  Appetizr
//
//  Created by dasdom on 17.11.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHOpenWebsiteActivity.h"

@interface DHOpenWebsiteActivity ()
@property (nonatomic, strong) NSArray *activityItems;
@end

@implementation DHOpenWebsiteActivity

- (NSString*)activityType {
    return @"openInSafariType";
}

- (NSString*)activityTitle {
    return @"Safari";
}

- (UIImage*)activityImage {
    return [UIImage imageNamed:@"safariIcon"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    self.activityItems = activityItems;
}

- (void)performActivity {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.activityItems objectAtIndex:0]]];
    [self activityDidFinish:YES];
}

@end
