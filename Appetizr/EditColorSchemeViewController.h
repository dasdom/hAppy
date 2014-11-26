//
//  EditColorSchemeViewController.h
//  Appetizr
//
//  Created by dasdom on 16.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditColorSchemeViewController : UIViewController

@property (nonatomic, strong) UIColor *mainColor;
@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, strong) UIColor *markedCellBackgroundColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *linkColor;
@property (nonatomic, strong) UIColor *mentionColor;
@property (nonatomic, strong) UIColor *hashTagColor;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *markerColor;
@property (nonatomic, strong) UIColor *separatorColor;

- (void)setColorsFromAnnotationDictionary:(NSDictionary*)annotationDictionary;

@end
