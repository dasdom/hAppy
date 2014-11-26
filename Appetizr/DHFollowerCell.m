//
//  DHFollowerCell.m
//  Appetizr
//
//  Created by dasdom on 29.09.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHFollowerCell.h"

@interface FollowerContentView : UIView {
    DHFollowerCell *_followerCell;
}
@end

@implementation FollowerContentView

- (id)initWithFrame:(CGRect)frame cell:(DHFollowerCell*)cell
{
    if (self = [super initWithFrame:frame]) {
        
        _followerCell = cell;
        self.opaque = YES;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [_followerCell.avatarImage drawInRect:CGRectMake(0.0f, 0.0f, 106.0f, 106.0f)];
    
}

@end

@implementation DHFollowerCell

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//
//        _followerContentView = [[FollowerContentView alloc] initWithFrame:self.contentView.bounds cell:self];
//        _followerContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        _followerContentView.contentMode = UIViewContentModeRedraw;
//        [self.contentView addSubview:_followerContentView];
//        
//        _moreInfoHostView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 26.0f, 106.0f, 60.0f)];
//        [self addSubview:_moreInfoHostView];
//        
//        _moreInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 96.0f, 60.0f)];
//        [_moreInfoLabel setTextColor:[UIColor whiteColor]];
//        [_moreInfoLabel setFont:[UIFont systemFontOfSize:12.0f]];
//        [_moreInfoLabel setNumberOfLines:3];
//        [_moreInfoHostView addSubview:_moreInfoLabel];
//
//    }
//    return self;
//}
//
- (void)awakeFromNib {
//    _followerContentView = [[FollowerContentView alloc] initWithFrame:self.contentView.bounds cell:self];
//    _followerContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    _followerContentView.contentMode = UIViewContentModeRedraw;
//    [self.contentView addSubview:_followerContentView];

    _moreInfoHostView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 26.0f, 106.0f, 60.0f)];
    [self.contentView addSubview:_moreInfoHostView];
    
    _moreInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 96.0f, 60.0f)];
    [_moreInfoLabel setTextColor:[UIColor whiteColor]];
    [_moreInfoLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_moreInfoLabel setNumberOfLines:3];
    [_moreInfoHostView addSubview:_moreInfoLabel];
    
    _moreInfoHostView.hidden = YES;
    
    [self bringSubviewToFront:self.iFollowBannerImageView];
    [self bringSubviewToFront:self.followerContentView];
}
//
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kDarkMode]) {
        _moreInfoLabel.backgroundColor = kDarkMainColor;
        _moreInfoHostView.backgroundColor = kDarkMainColor;
    } else {
        _moreInfoLabel.backgroundColor = kMainColor;
        _moreInfoHostView.backgroundColor = kMainColor;
    }
}
//
//- (void)setAvatarImage:(UIImage *)avatarImage {
//    _avatarImage = avatarImage;
//    [self.followerContentView setNeedsDisplay];
//}


@end
