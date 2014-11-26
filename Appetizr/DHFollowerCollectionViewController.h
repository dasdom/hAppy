//
//  DHFollowerCollectionViewController.h
//  Appetizr
//
//  Created by dasdom on 29.09.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHFollowerCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *nameString;

@property (nonatomic, strong) NSNumber *showIFollowBanner;
@property (nonatomic, strong) NSNumber *showFollowsMeBanner;

@end
