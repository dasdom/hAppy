//
//  NSFileManager+DirectorySize.m
//  Appetizr
//
//  Created by dasdom on 14.07.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "NSFileManager+DirectorySize.h"

@implementation NSFileManager (DirectorySize)

- (unsigned long long)contentSizeOfDirectoryAtURL:(NSURL *)directoryURL
{
    unsigned long long contentSize = 0;
    NSDirectoryEnumerator *enumerator = [self enumeratorAtURL:directoryURL includingPropertiesForKeys:[NSArray arrayWithObject:NSURLFileSizeKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:NULL];
    NSNumber *value = nil;
    for (NSURL *itemURL in enumerator) {
        if ([itemURL getResourceValue:&value forKey:NSURLFileSizeKey error:NULL]) {
            contentSize += value.unsignedLongLongValue;
        }
    }
    return contentSize;
}

@end
