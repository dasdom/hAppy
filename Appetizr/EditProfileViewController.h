//
//  EditProfileViewController.h
//  Appetizr
//
//  Created by dasdom on 03.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

enum IMAGE_INDEX {
    IMAGE_AVATAR_INDEX = 0,
    IMAGE_COVER_INDEX
    } IMAGE_INDEX;

@interface EditProfileViewController : UIViewController

@property (nonatomic, strong) NSDictionary *userDictionary;
@property (nonatomic, strong) UIImage *avatarImage;
@property (nonatomic, strong) UIImage *coverImage;
@property (nonatomic, strong) NSString *postText;

@property (nonatomic) BOOL updateAvatar;
@property (nonatomic) BOOL updateCover;
@end
