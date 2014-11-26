//
//  PostDetailsPostCell.h
//  Appetizr
//
//  Created by Dominik Hauser on 17.02.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DHPostTextView.h"

@interface PostDetailsPostCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *userNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *postDateLabel;
@property (nonatomic, strong) IBOutlet DHPostTextView *postTextView;
@property (nonatomic, strong) IBOutlet UILabel *clientLabel;
@property (nonatomic, strong) IBOutlet UIImageView *postImage;
@property (nonatomic, strong) NSString *userId;

@end
