//
//  DHFontSizeCell.h
//  Appetizr
//
//  Created by dasdom on 03.11.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHFontSizeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *fontSizeLabel;
@property (nonatomic, weak) IBOutlet UIStepper *fontSizeStepper;

@end
