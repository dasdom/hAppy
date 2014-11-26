//
//  EditImageMaskViewController.h
//  Appetizr
//
//  Created by dasdom on 03.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditProfileViewController.h"

@interface EditImageMaskViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImage *imageToMask;
@property (nonatomic, weak) EditProfileViewController *editProfileViewController;
@property (nonatomic) NSInteger imageTypeIndex;

@end
