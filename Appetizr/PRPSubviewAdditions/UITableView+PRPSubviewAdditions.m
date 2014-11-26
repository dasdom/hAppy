/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  UITableView+PRPSubviewAdditions.m
//  CellSubviewLocation
//
//  Created by Matt Drance on 9/9/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//

#import "UITableView+PRPSubviewAdditions.h"

@implementation UITableView (PRPSubviewAdditions)

- (NSIndexPath *)prp_indexPathForRowContainingView:(UIView *)view {
    CGPoint correctedPoint = [view convertPoint:view.bounds.origin
                                         toView:self];
    return [self indexPathForRowAtPoint:correctedPoint];    
}

@end
