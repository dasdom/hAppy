//
//  UIImage+NormalizedImage.m
//  Appetizr
//
//  Created by dasdom on 03.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "UIImage+NormalizedImage.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation UIImage (NormalizedImage)

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

- (UIImage *)resizeImage:(CGSize)imgSize {
    UIGraphicsBeginImageContext(imgSize);
    [self drawInRect:CGRectMake(0,0,imgSize.width,imgSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
