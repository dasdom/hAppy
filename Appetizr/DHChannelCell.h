//
//  DHChannelCell.h
//  Appetizr
//
//  Created by dasdom on 17.12.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHChannelCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *previewLabel;
@property (nonatomic, weak) IBOutlet UIImageView *indicatorImageView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *usersLabel;
@property (nonatomic, weak) IBOutlet UIView *customSeparatorView;

@end
