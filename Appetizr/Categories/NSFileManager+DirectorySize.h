//
//  NSFileManager+DirectorySize.h
//  Appetizr
//
//  Created by dasdom on 14.07.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (DirectorySize)

- (unsigned long long)contentSizeOfDirectoryAtURL:(NSURL *)directoryURL;

@end
