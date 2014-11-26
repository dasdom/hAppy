//
//  LinkCreationViewController.h
//  Appetizr
//
//  Created by dasdom on 24.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DHCreateStatusViewController;

@interface LinkCreationViewController : UIViewController

@property (nonatomic, weak) DHCreateStatusViewController *createStatusViewController;
@property (nonatomic, strong) NSString *linkText;

@end
