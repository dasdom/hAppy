//
//  DHFollowerCell.h
//  Appetizr
//
//  Created by dasdom on 29.09.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHFollowerCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iFollowBannerImageView;
@property (nonatomic, weak) IBOutlet UIImageView *followsMeBannerImageView;
@property (nonatomic, strong) IBOutlet UIView *moreInfoHostView;
@property (nonatomic, strong) IBOutlet UILabel *moreInfoLabel;

@property (nonatomic, strong) UIView *followerContentView;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) NSString *nameString;

@end
