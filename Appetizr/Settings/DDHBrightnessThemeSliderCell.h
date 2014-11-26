//
//  DDHBrightnessThemeSliderCell.h
//  Appetizr
//
//  Created by dasdom on 09.02.14.
//  Copyright (c) 2014 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDHBrightnessThemeSliderCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *cellLabel;
@property (nonatomic, weak) IBOutlet UISwitch *automaticSwitch;
@property (nonatomic, weak) IBOutlet UISlider *brightnessSlider;
@property (nonatomic, weak) IBOutlet UIView *currentBrighnessView;
@end
