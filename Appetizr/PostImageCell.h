//
//  PostImageCell.h
//  Appetizr
//
//  Created by dasdom on 09.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostImageCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *postImageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingActivityIndicatorView;
@property (nonatomic, strong) UIView *labelHostView;
@property (nonatomic, strong) UILabel *postLabel;

@end
