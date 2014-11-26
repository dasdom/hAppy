//
//  DHPostImageViewController.h
//  Appetizr
//
//  Created by dasdom on 03.02.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHPostImageViewController : UIViewController

@property (nonatomic, strong) NSString *postImageURL;
@property (nonatomic, strong) UIImage *postImage;

- (id)initWithPostImageURL:(NSString*)postImageURL;
@end
