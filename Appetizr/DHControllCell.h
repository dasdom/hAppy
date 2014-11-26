//
//  DHControllCell.h
//  Appetizr
//
//  Created by dasdom on 20.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PRPSmartTableViewCell.h"

@interface DHControllCell : PRPSmartTableViewCell

@property (nonatomic, strong) IBOutlet UIButton *profileButton;
@property (nonatomic, strong) IBOutlet UIButton *repostButton;
@property (nonatomic, strong) IBOutlet UIButton *conversationButton;
@property (nonatomic, strong) IBOutlet UIButton *starButton;
@property (nonatomic, strong) IBOutlet UIButton *replyButton;
@property (nonatomic, strong) IBOutlet UIButton *metaDataButton;

//@property (nonatomic, weak) IBOutlet UILabel *clientLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfRepostsLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfStarsLabel;
@property (nonatomic, strong) IBOutlet UILabel *numberOfRepliesLabel;
@property (nonatomic, strong) IBOutlet UILabel *userIdLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicatorView;

//@property (nonatomic, strong) UITextField *textField;

@end
