//
//  DHCreatePostViewController.h
//  Appetizr
//
//  Created by dasdom on 16.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHCreateStatusViewController : UIViewController

@property (nonatomic, strong) NSString *consigneeString;
@property (nonatomic, strong) NSArray *consigneeArray;
@property (nonatomic, strong) NSString *replyToId;
@property (nonatomic, strong) NSString *replyToText;
@property (nonatomic, strong) NSString *quoteString;
@property (nonatomic, strong) NSString *channelId;
@property (nonatomic, strong) NSString *draftText;
@property (nonatomic, strong) NSString *channelTitle;

@property (nonatomic, strong) NSString *locationId;

@property (nonatomic, strong) NSNumber *imageWithHighQuality;
@property (nonatomic, strong) NSDictionary *themeAnnotationDictionary;

@property (nonatomic, strong) NSArray *annotationsArray;
@property (nonatomic, strong) NSArray *quoteLinksArray;

@property (nonatomic) BOOL isPrivateMessage;

- (void)addConsignee:(NSString*)name;
- (void)addLink:(NSDictionary*)linkDictionary;

@end
