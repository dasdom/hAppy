//
//  PostDetailWebSiteCell.h
//  Appetizr
//
//  Created by dasdom on 01.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostDetailWebSiteCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *urlString;

@end
