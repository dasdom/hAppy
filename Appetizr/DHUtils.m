//
//  DHUtils.m
//  Appetizr
//
//  Created by dasdom on 13.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHUtils.h"

@implementation DHUtils

+ (NSString*)stringOrEmpty:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    } else {
        return @"";
    }
}

@end
