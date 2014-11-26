//
//  UIColor+StringConversion.h
//  Appetizr
//
//  Created by dasdom on 30.05.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (StringConversion)

+ (UIColor*)colorWithString:(NSString*)colorString;
- (NSString*)stringValue;

@end
