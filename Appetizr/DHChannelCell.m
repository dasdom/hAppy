//
//  DHChannelCell.m
//  Appetizr
//
//  Created by dasdom on 17.12.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHChannelCell.h"

@implementation DHChannelCell

- (void)awakeFromNib {
    self.avatarImageView.layer.cornerRadius = 6.0f;
    self.avatarImageView.clipsToBounds = YES;
}

//- (void)drawRect:(CGRect)rect {
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        self.contentView.backgroundColor = kDarkCellBackgroundColorDefault;
//        self.userNameLabel.textColor = kDarkTextColor;
//        self.dateLabel.textColor = kDarkTextColor;
//        self.previewLabel.textColor = kDarkTextColor;
//    } else {
//        self.contentView.backgroundColor = kLightCellBackgroundColorDefault;
//        self.userNameLabel.textColor = kLightTextColor;
//        self.dateLabel.textColor = kLightTextColor;
//        self.previewLabel.textColor = kLightTextColor;
//    }
//}

@end
