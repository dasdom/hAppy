//
//  EditImageMaskViewController.m
//  Appetizr
//
//  Created by dasdom on 03.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "EditImageMaskViewController.h"
#import "DHActionSheet.h"
#import "PRPAlertView.h"
#import "UIImage+NormalizedImage.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface EditImageMaskViewController ()
@property (nonatomic, strong) UIImage *imageFromSource;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIPopoverController *popOverController;
@end

@implementation EditImageMaskViewController

- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height;
    
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, frame.size.width-20.0f, 400.0f)];
    _imageView.userInteractionEnabled = YES;
    _imageView.multipleTouchEnabled = YES;
    [contentView addSubview:_imageView];
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    if ([userdefaults boolForKey:kDarkMode]) {
//        contentView.backgroundColor = kDarkCellBackgroundColorDefault;
        contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
    } else {
        contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
    }
        
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveButtonTouched:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.imageFromSource) {
        DHActionSheet *actionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"chose image source", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"camera", nil), NSLocalizedString(@"gallery", nil),
                                      //NSLocalizedString(@"last photo", nil),
                                      nil];
        actionSheet.tag = 101;
        [actionSheet showInView:self.view];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)actionSheet:(DHActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 101) {
        if (buttonIndex == 0) {
//            [self performSegueWithIdentifier:@"ShowImagePicker" sender:@"camera"];
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:^{}];
        } else if (buttonIndex == 1) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
                self.popOverController = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
                [self.popOverController presentPopoverFromRect:CGRectMake(0.0f, 0.0f, 320.0f, 320.0f) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                [self presentViewController:imagePicker animated:YES completion:^{}];
            }
        } else if (buttonIndex == 2) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                
                // Within the group enumeration block, filter to enumerate just photos.
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                
                // Chooses the photo at the last index
                [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
                    
                    // The end of the enumeration is signaled by asset == nil.
                    if (alAsset) {
                        ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                        UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
                        
                        self.imageFromSource = latestPhoto;
                    }
                }];
            } failureBlock: ^(NSError *error) {
                // Typically you should handle an error more gracefully than this.
                dhDebug(@"No groups");
            }];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)) {
        [self.popOverController dismissPopoverAnimated:NO];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
    dhDebug(@"info: %@", info);
    self.imageFromSource = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGSize postImageSize = self.imageFromSource.size;
    CGRect postImageViewFrame = self.imageView.frame;
    if (postImageSize.width > 0.0f && postImageSize.height > 0.0f) {
        if ((postImageSize.height / postImageSize.width) < (postImageViewFrame.size.height / postImageViewFrame.size.width)) {
            postImageViewFrame.size.height = postImageViewFrame.size.width * postImageSize.height / postImageSize.width;
        } else {
            postImageViewFrame.size.width = postImageViewFrame.size.height * postImageSize.width / postImageSize.height;
        }
//        postImageViewFrame.origin.x = (contentView.frame.size.width - postImageViewFrame.size.width)/2.0f;
//        postImageViewFrame.origin.y = (contentView.frame.size.height - postImageViewFrame.size.height)/2.0f;
        self.imageView.frame = postImageViewFrame;
    }

    
    self.imageView.image = self.imageFromSource;

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {    
    if ([[event touchesForView:self.imageView] count] != 2) {
        return;
    }
    
    NSArray *touchesArray = [[event touchesForView:self.imageView] allObjects];
    CGPoint firstPoint = [[touchesArray objectAtIndex:0] locationInView:self.view];
    CGPoint secondPoint = [[touchesArray objectAtIndex:1] locationInView:self.view];
    
    if (!self.maskView) {
        CGFloat width, height;
        if (self.imageTypeIndex == IMAGE_AVATAR_INDEX) {
            width = height = MAX(abs(firstPoint.x-secondPoint.x),abs(firstPoint.y-secondPoint.y));
        } else {
            width = abs(firstPoint.x-secondPoint.x);
            height = abs(firstPoint.y-secondPoint.y);
        }
        self.maskView = [[UIView alloc] initWithFrame:CGRectMake(MIN(firstPoint.x, secondPoint.x), MIN(firstPoint.y, secondPoint.y), width, height)];
        self.maskView.userInteractionEnabled = NO;
    }
    self.maskView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4f];
    [self.view addSubview:self.maskView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([[event touchesForView:self.imageView] count] != 2) {
        return;
    }
    
    NSArray *touchesArray = [[event touchesForView:self.imageView] allObjects];
    CGPoint firstPoint = [[touchesArray objectAtIndex:0] locationInView:self.view];
    CGPoint secondPoint = [[touchesArray objectAtIndex:1] locationInView:self.view];
    
    CGFloat width, height;
    if (self.imageTypeIndex == IMAGE_AVATAR_INDEX) {
        width = height = MAX(abs(firstPoint.x-secondPoint.x),abs(firstPoint.y-secondPoint.y));
    } else {
        width = abs(firstPoint.x-secondPoint.x);
        height = abs(firstPoint.y-secondPoint.y);
    }
    self.maskView.frame = CGRectMake(MIN(firstPoint.x, secondPoint.x), MIN(firstPoint.y, secondPoint.y), width, height);
}

- (void)saveButtonTouched:(UIBarButtonItem*)sender {
    if (!self.maskView) {
        [PRPAlertView showWithTitle:NSLocalizedString(@"No mask", nil) message:NSLocalizedString(@"Please touch the image with two fingers to adjust the size of the image.", nil) buttonTitle:@"OK"];
        return;
    }
    
    CGSize imageSize = self.imageView.image.size;
    CGSize imageViewSize = self.imageView.frame.size;
    CGFloat maskWidth;
    CGFloat maskHeight;
    dhDebug(@"self.imageFromSource.imageOrientation: %d", self.imageFromSource.imageOrientation);
//    if (self.imageFromSource.imageOrientation == UIImageOrientationLeft || self.imageFromSource.imageOrientation == UIImageOrientationRight) {
//        maskHeight = self.maskView.frame.size.width*imageSize.height/imageViewSize.height;
//        maskWidth = self.maskView.frame.size.height*imageSize.width/imageViewSize.width;
//    } else {
        maskWidth = self.maskView.frame.size.width*imageSize.width/imageViewSize.width;
        maskHeight = self.maskView.frame.size.height*imageSize.height/imageViewSize.height;
//    }
    CGRect maskFrame = CGRectMake(self.maskView.frame.origin.x*imageSize.width/imageViewSize.width, self.maskView.frame.origin.y*imageSize.height/imageViewSize.height, self.maskView.frame.size.width*imageSize.width/imageViewSize.width, self.maskView.frame.size.height*imageSize.height/imageViewSize.height);
    
    // Create rectangle that represents a cropped image
    // from the middle of the existing image
    CGRect rect = [self.view convertRect:maskFrame toView:self.imageView];
    dhDebug(@"self.maskView.frame: %@, rect: %@", NSStringFromCGRect(self.maskView.frame), NSStringFromCGRect(rect));
    
    UIImage *normalizedImage = [self.imageFromSource normalizedImage];
    
    // Create bitmap image from original image data,
    // using rectangle to specify desired crop area
    CGImageRef imageRef = CGImageCreateWithImageInRect([normalizedImage CGImage], rect);
    UIImage *img = [UIImage imageWithCGImage:imageRef
                                       //scale:1.0f orientation:self.imageFromSource.imageOrientation
                    ];
    CGImageRelease(imageRef);
    
    
    if (self.imageTypeIndex == IMAGE_AVATAR_INDEX) {
        if (rect.size.width < 200.0f) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Image to small", nil) message:NSLocalizedString(@"The avatar image must be at least 200x200 pixels.", nil) buttonTitle:@"OK"];
            return;
        }
        self.editProfileViewController.avatarImage = img;
        self.editProfileViewController.updateAvatar = YES;
    } else {
        if (rect.size.width < 960.0f) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Image to small", nil) message:NSLocalizedString(@"The cover image must be at least 960 pixels wide.", nil) buttonTitle:@"OK"];
            return;
        }
        self.editProfileViewController.coverImage = img;
        self.editProfileViewController.updateCover = YES;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end
