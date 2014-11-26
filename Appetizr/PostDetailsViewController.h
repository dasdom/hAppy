//
//  PostDetailsViewController.h
//  Appetizr
//
//  Created by dasdom on 12.02.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostDetailsViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString *postId;

@end
