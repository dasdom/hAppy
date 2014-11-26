//
//  DHAppDelegate.h
//  Appetizr
//
//  Created by dasdom on 12.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "ADNLogin.h"

@interface DHAppDelegate : UIResponder <UIApplicationDelegate, ADNLoginDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSCache *avatarCache;
@property (nonatomic, strong) Reachability* internetReach;
//@property (strong, nonatomic) ADNLogin *adn;

@property (nonatomic, strong, readonly) NSString *returnURLString;

- (void)returnToCaller;

@end
