//
//  SplitMasterViewController.h
//  Appetizr
//
//  Created by dasdom on 21.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHSplitViewController.h"

@class DHUserStreamTableViewController;

enum BUTTON_TAGS {
    BUTTON_TAG_UNIVERSAL = 100,
    BUTTON_TAG_MENTIONS,
    BUTTON_TAG_GLOBAL,
    BUTTON_TAG_MESSAGES,
    BUTTON_TAG_PATTER,
    BUTTON_TAG_PROFILE,
    BUTTON_TAG_INTERACTIONS,
    BUTTON_TAG_HASHTAGSEARCH
} BUTTON_TAGS;

@interface SplitMasterViewController : UIViewController <UISplitViewControllerDelegate>

@property (nonatomic, strong) DHUserStreamTableViewController *userStreamTableViewController;
@property (nonatomic, weak) id detailViewController;

- (void)setColors;
- (void)selectButtonWithTag:(NSInteger)buttonTag;

@end
