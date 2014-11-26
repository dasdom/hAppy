//
//  UIImage+NormalizedImage.h
//  Appetizr
//
//  Created by dasdom on 03.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (NormalizedImage)

- (UIImage *)normalizedImage;
- (UIImage *)resizeImage:(CGSize)imgSize;

@end
