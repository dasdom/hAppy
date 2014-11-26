//
//  DHLicenceViewController.m
//  Appetizr
//
//  Created by dasdom on 09.02.14.
//  Copyright (c) 2014 dasdom. All rights reserved.
//

#import "DHLicenceViewController.h"

@interface DHLicenceViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@end

@implementation DHLicenceViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.title = _dataDictionary[@"name"];
    [_titleButton setTitle:_dataDictionary[@"link"] forState:UIControlStateNormal];
    _textView.text = [NSString stringWithFormat:@"%@", _dataDictionary[@"licence"]];
}

- (IBAction)showWebsite:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_dataDictionary[@"link"]]];
}

@end
