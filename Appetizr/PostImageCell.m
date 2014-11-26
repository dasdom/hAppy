//
//  PostImageCell.m
//  Appetizr
//
//  Created by dasdom on 09.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "PostImageCell.h"

@implementation PostImageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _postImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:_postImageView];
        
        _loadingActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        [_loadingActivityIndicatorView startAnimating];
        _loadingActivityIndicatorView.hidesWhenStopped = YES;
        _loadingActivityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_loadingActivityIndicatorView];
        
        _labelHostView = [[UIView alloc] initWithFrame:self.bounds];
        _labelHostView.backgroundColor = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.8f];
//        _labelHostView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_labelHostView];
        
        CGRect labelFrame = CGRectMake(10.0f, 10.0f, self.bounds.size.width-20.0f, self.bounds.size.height-20.0f);
        _postLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _postLabel.backgroundColor = [UIColor clearColor];
        _postLabel.numberOfLines = 0;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//            _postLabel.textColor = kDarkTintColor;
            _postLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        } else {
            _postLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        }
        _postLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_labelHostView addSubview:_postLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
