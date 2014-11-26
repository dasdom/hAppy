//
//  DHPostCell.h
//  Appetizr
//
//  Created by dasdom on 14.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRPSmartTableViewCell.h"
#import "DHPostTextView.h"

@interface DHPostCell : PRPSmartTableViewCell

@property (nonatomic, strong) UIImage *shadowImageView;

@property (nonatomic, strong) UIView *postContentView;

@property (nonatomic, copy) NSString *clientString;

@property (nonatomic, strong) IBOutlet DHPostTextView *postTextView;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, copy) NSString *nameString;

@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) UIImage *postImage;
@property (nonatomic, strong) UIColor *postColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGRect postImageFrame;
@property (nonatomic, strong) UIColor *customSeparatorColor;

@property (nonatomic, strong) NSString *userId;
@property (nonatomic) BOOL iAmFollowing;
@property (nonatomic) BOOL followsMe;

@property (nonatomic, assign) BOOL faved;

@property (nonatomic, strong) NSString *canonical_url;
@property (nonatomic, strong) NSString *postImageURL;
@property (nonatomic, strong) NSString *postVideoURL;
@property (nonatomic) BOOL isFocused;
@property (nonatomic) BOOL noImages;
@property (nonatomic) BOOL noClient;

@property (nonatomic) BOOL drawAvatarRight;
@property (nonatomic) BOOL isSelectedCell;

@property (nonatomic, strong) UIImageView *actionImageView;
@property (nonatomic, strong) UILabel *idLabel;
@property (nonatomic, strong) UIImageView *conversationImageView;

@property (nonatomic, strong) UIView *buttonHostView;
@property (nonatomic, strong) UIButton *replyButton;
@property (nonatomic, strong) UIButton *repostButton;
@property (nonatomic, strong) UIButton *conversationButton;
@property (nonatomic, strong) UIButton *starButton;
@property (nonatomic, strong) UIButton *infoButton;
@property (nonatomic, strong) UIButton *cancelButton;

- (CGRect)avatarFrame;
- (BOOL)toggleActionButtonView;
- (void)setActionButtonViewHidden:(BOOL)hidden;

@end
