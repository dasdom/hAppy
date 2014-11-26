//
//  EditProfileViewController.m
//  Appetizr
//
//  Created by dasdom on 03.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "EditProfileViewController.h"
#import "DHActionSheet.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "EditImageMaskViewController.h"
#import "SSKeychain.h"
#import "PRPConnection.h"
#import "PRPAlertView.h"

@interface EditProfileViewController () 
@property (nonatomic, strong) UITextView *bioTextView;
@property (nonatomic) NSRange startRange;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic) NSInteger imageIndex;
@end

@implementation EditProfileViewController


- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height;
    
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:contentView.bounds];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    UITapGestureRecognizer *tapOnBackgroundRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnBackgroundHappend:)];
    [scrollView addGestureRecognizer:tapOnBackgroundRecognizer];
    
    _bioTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, contentView.frame.size.width-20.0f, 80.0f)];
    _bioTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [scrollView addSubview:_bioTextView];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHappend:)];
    [_bioTextView addGestureRecognizer:panGestureRecognizer];
    
    _avatarImageView = [[UIImageView alloc] initWithImage:self.avatarImage];
    _avatarImageView.frame = CGRectMake((contentView.frame.size.width-100.0f)/2.0f, 110.0f, 100.0f, 100.0f);
    _avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    UITapGestureRecognizer *avatarTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTouched:)];
    [_avatarImageView addGestureRecognizer:avatarTapRecognizer];
    _avatarImageView.userInteractionEnabled = YES;
    _avatarImageView.tag = IMAGE_AVATAR_INDEX;
    _avatarImageView.isAccessibilityElement = NO;
    [scrollView addSubview:_avatarImageView];
    
    if (self.coverImage) {
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake((contentView.frame.size.width-300.0f)/2.0f, 240.0f, 300.0f, self.coverImage.size.height*300.0f/self.coverImage.size.width)];
        _coverImageView.image = self.coverImage;
    } else {
        _coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake((contentView.frame.size.width-300.0f)/2.0f, 240.0f, 300.0f, 100.0f)];
    }
    _coverImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _coverImageView.tag = IMAGE_COVER_INDEX;
    _coverImageView.isAccessibilityElement = NO;
    [scrollView addSubview:_coverImageView];

    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, _coverImageView.frame.origin.y+_coverImageView.frame.size.height+20.0f);
    
    UITapGestureRecognizer *coverTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pictureTouched:)];
    [_coverImageView addGestureRecognizer:coverTapRecognizer];
    _coverImageView.userInteractionEnabled = YES;
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    if ([userdefaults boolForKey:kDarkMode]) {
//        scrollView.backgroundColor = kDarkCellBackgroundColorDefault;
//        _bioTextView.backgroundColor = kDarkCellBackgroundColorMarked;
//        _coverImageView.backgroundColor = kDarkCellBackgroundColorMarked;
//        _bioTextView.textColor = kDarkTextColor;
//        [self.navigationController.navigationBar setTintColor:kDarkMainColor];
        scrollView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        _bioTextView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        _coverImageView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        _bioTextView.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            self.navigationController.navigationBar.barTintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
            self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        }
        else
        {
            self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
        }
    } else {
        scrollView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        _bioTextView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        _coverImageView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        _bioTextView.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            self.navigationController.navigationBar.barTintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
            self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        }
        else
        {
            self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
        }
    }
    
    self.title = NSLocalizedString(@"edit profile", nil);
    
    [contentView addSubview:scrollView];
    
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSDictionary *descriptionDictionary = [self.userDictionary objectForKey:@"description"];
    NSString *postText = [DHUtils stringOrEmpty:[descriptionDictionary objectForKey:@"text"]];
    
    self.bioTextView.text = postText;
    
    UIBarButtonItem *saveBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"save", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(saveChanges:)];
    self.navigationItem.rightBarButtonItem = saveBarButton;
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancelChanges:)];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.avatarImageView.image = self.avatarImage;
    self.coverImageView.image = self.coverImage;
    self.coverImageView.frame = CGRectMake((self.view.frame.size.width-300.0f)/2.0f, 240.0f, 300.0f, self.coverImage.size.height*300.0f/self.coverImage.size.width);

    self.title = NSLocalizedString(@"edit profile", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)saveChanges:(UIBarButtonItem*)sender {
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    
    if (self.bioTextView.text) {
        dhDebug(@"self.bioTextView.text: %@", self.bioTextView.text);
        NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", accessToken];
        
        NSDictionary *updateDictionary = @{@"name": [self.userDictionary objectForKey:@"name"], @"locale": [self.userDictionary objectForKey:@"locale"], @"timezone": [self.userDictionary objectForKey:@"timezone"], @"description": @{@"text": self.bioTextView.text}};
        
        NSMutableURLRequest *bioUploadRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://alpha-api.app.net/stream/0/users/me/"]];
        [bioUploadRequest addValue:authorizationString forHTTPHeaderField:@"Authorization"];
        [bioUploadRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [bioUploadRequest setHTTPMethod:@"PUT"];
        
        [bioUploadRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:updateDictionary options:kNilOptions error:nil]];
        
        __weak EditProfileViewController *weakSelf = self;

        PRPConnection *bioPutConnection = [PRPConnection connectionWithRequest:bioUploadRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//        [DHConnection connectionWithRequest:bioUploadRequest progress:^(DHConnection *connection) {
//            dhDebug(@"progress");
//        } completion:^(DHConnection *connection, NSError *error) {
            NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
            dhDebug(@"Image upload responseDict: %@", responseDict);
            if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
                [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
                return;
            }
            
            if (!weakSelf.updateAvatar && !weakSelf.updateCover) {
                [weakSelf dismissViewControllerAnimated:YES completion:^{}];
            }
            if (self.updateAvatar && self.avatarImage) {
                
                NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", accessToken];
                
                NSData *imageData = UIImageJPEGRepresentation(self.avatarImage, 200.0f/self.avatarImage.size.width);
                
                NSMutableURLRequest *imageUploadRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://alpha-api.app.net/stream/0/users/me/avatar"]];
                [imageUploadRequest addValue:authorizationString forHTTPHeaderField:@"Authorization"];
                [imageUploadRequest setHTTPMethod:@"POST"];
                NSString *boundary = @"82481319dca6";
                NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                [imageUploadRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
                NSMutableData *postbody = [NSMutableData data];
                [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:[@"Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:imageData];
                [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
                [imageUploadRequest setHTTPBody:postbody];
                
                PRPConnection *imagePostConnection = [PRPConnection connectionWithRequest:imageUploadRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//                [DHConnection connectionWithRequest:imageUploadRequest progress:^(DHConnection *connection) {
//                    dhDebug(@"progress");
//                } completion:^(DHConnection *connection, NSError *error) {
                    NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
                    dhDebug(@"Image upload responseDict: %@", responseDict);
                    if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
                        [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
                        return;
                    }
                    
                    weakSelf.updateAvatar = NO;
                    if (!weakSelf.updateAvatar && !weakSelf.updateCover) {
                        [weakSelf dismissViewControllerAnimated:YES completion:^{}];
                    }
                }];
                [imagePostConnection start];
            }
            
            if (self.updateCover && self.coverImage) {
                
                NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", accessToken];
                
                NSData *imageData = UIImageJPEGRepresentation(self.coverImage, 900.0f/self.coverImage.size.width);
                
                NSMutableURLRequest *imageUploadRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://alpha-api.app.net/stream/0/users/me/cover"]];
                [imageUploadRequest addValue:authorizationString forHTTPHeaderField:@"Authorization"];
                [imageUploadRequest setHTTPMethod:@"POST"];
                NSString *boundary = @"82481319dca6";
                NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
                [imageUploadRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
                NSMutableData *postbody = [NSMutableData data];
                [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:[@"Content-Disposition: form-data; name=\"cover\"; filename=\"cover\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [postbody appendData:imageData];
                [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                
                [imageUploadRequest setHTTPBody:postbody];
                
                PRPConnection *imagePostConnection = [PRPConnection connectionWithRequest:imageUploadRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//                [DHConnection connectionWithRequest:imageUploadRequest progress:^(DHConnection *connection) {
//                    dhDebug(@"progress");
//                } completion:^(DHConnection *connection, NSError *error) {
                    NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
                    dhDebug(@"Image upload responseDict: %@", responseDict);
                    if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
                        [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
                        return;
                    }
                    weakSelf.updateCover = NO;
                    if (!weakSelf.updateAvatar && !weakSelf.updateCover) {
                        [weakSelf dismissViewControllerAnimated:YES completion:^{}];
                    }
                    
                }];
                [imagePostConnection start];
            }

        }];
        [bioPutConnection start];

    }
    
//    if (self.updateAvatar && self.avatarImage) {
//
//        NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", accessToken];
//        
//        NSData *imageData = UIImageJPEGRepresentation(self.avatarImage, 200.0f/self.avatarImage.size.width);
//        
//        NSMutableURLRequest *imageUploadRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://alpha-api.app.net/stream/0/users/me/avatar"]];
//        [imageUploadRequest addValue:authorizationString forHTTPHeaderField:@"Authorization"];
//        [imageUploadRequest setHTTPMethod:@"POST"];
//        NSString *boundary = @"82481319dca6";
//        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
//        [imageUploadRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
//        NSMutableData *postbody = [NSMutableData data];
//        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [postbody appendData:[@"Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [postbody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [postbody appendData:imageData];
//        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        [imageUploadRequest setHTTPBody:postbody];
//        
//        __weak EditProfileViewController *weakSelf = self;
//        DHConnection *imagePostConnection = [DHConnection connectionWithRequest:imageUploadRequest progress:^(DHConnection *connection) {
//            dhDebug(@"progress");
//        } completion:^(DHConnection *connection, NSError *error) {
//            NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//            NSLog(@"Image upload responseDict: %@", responseDict);
//            if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
//                [DHAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
//                return;
//            }
//            
//            weakSelf.updateAvatar = NO;
//            if (!weakSelf.updateAvatar && !weakSelf.updateCover) {
//                [self dismissViewControllerAnimated:YES completion:^{}];
//            }
//        }];
//        [imagePostConnection start];
//    }
//    
//    if (self.updateCover && self.coverImage) {
//               
//        NSString *authorizationString = [NSString stringWithFormat:@"Bearer %@", accessToken];
//        
//        NSData *imageData = UIImageJPEGRepresentation(self.coverImage, 900.0f/self.coverImage.size.width);
//        
//        NSMutableURLRequest *imageUploadRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://alpha-api.app.net/stream/0/users/me/cover"]];
//        [imageUploadRequest addValue:authorizationString forHTTPHeaderField:@"Authorization"];
//        [imageUploadRequest setHTTPMethod:@"POST"];
//        NSString *boundary = @"82481319dca6";
//        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
//        [imageUploadRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
//        NSMutableData *postbody = [NSMutableData data];
//        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [postbody appendData:[@"Content-Disposition: form-data; name=\"cover\"; filename=\"cover\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [postbody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [postbody appendData:imageData];
//        [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        [imageUploadRequest setHTTPBody:postbody];
//        
//        __weak EditProfileViewController *weakSelf = self;
//        DHConnection *imagePostConnection = [DHConnection connectionWithRequest:imageUploadRequest progress:^(DHConnection *connection) {
//            dhDebug(@"progress");
//        } completion:^(DHConnection *connection, NSError *error) {
//            NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//            NSLog(@"Image upload responseDict: %@", responseDict);
//            if (error || [[[responseDict objectForKey:@"meta"] objectForKey:@"code"] integerValue] != 200) {
//                [DHAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription buttonTitle:@"OK"];
//                return;
//            }
//            weakSelf.updateCover = NO;
//            if (!weakSelf.updateAvatar && !weakSelf.updateCover) {
//                [self dismissViewControllerAnimated:YES completion:^{}];
//            }
//            
//        }];
//        [imagePostConnection start];
//    }

}

- (void)cancelChanges:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)tapOnBackgroundHappend:(UITapGestureRecognizer*)sender {
    [self.bioTextView resignFirstResponder];
}

- (void)panHappend:(UIPanGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.startRange = self.bioTextView.selectedRange;
    }
    
    NSRange selectedRange = {MAX(self.startRange.location+(NSInteger)([sender translationInView:self.view].x/5.0f), 0), 0};
    self.bioTextView.selectedRange = selectedRange;
}

- (void)pictureTouched:(UITapGestureRecognizer*)sender {
    EditImageMaskViewController *editImageMask = [[EditImageMaskViewController alloc] init];
    editImageMask.imageTypeIndex = sender.view.tag;
    editImageMask.editProfileViewController = self;
    [self.navigationController pushViewController:editImageMask animated:YES];
}

//    self.imageIndex = sender.view.tag;
//    DHActionSheet *actionSheet = [[DHActionSheet alloc] initWithTitle:NSLocalizedString(@"chose image source", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"camera", nil), NSLocalizedString(@"gallery", nil), NSLocalizedString(@"last photo", nil), nil];
//    actionSheet.tag = 101;
//    [actionSheet showInView:self.view];
//}
//
//- (void)actionSheet:(DHActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (actionSheet.tag == 101) {
//        if (buttonIndex == 0) {
//            [self performSegueWithIdentifier:@"ShowImagePicker" sender:@"camera"];
//        } else if (buttonIndex == 1) {
//            [self performSegueWithIdentifier:@"ShowImagePicker" sender:@"gallery"];
//        } else if (buttonIndex == 2) {
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
//                
//                // Within the group enumeration block, filter to enumerate just photos.
//                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
//                
//                // Chooses the photo at the last index
//                [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
//                    
//                    // The end of the enumeration is signaled by asset == nil.
//                    if (alAsset) {
//                        ALAssetRepresentation *representation = [alAsset defaultRepresentation];
//                        UIImage *latestPhoto = [UIImage imageWithCGImage:[representation fullScreenImage]];
//                        
//                        self.imageFromSource = latestPhoto;
//                    }
//                }];
//            } failureBlock: ^(NSError *error) {
//                // Typically you should handle an error more gracefully than this.
//                NSLog(@"No groups");
//            }];
//        }
//    }
//}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    [self dismissViewControllerAnimated:YES completion:^{}];
//    dhDebug(@"info: %@", info);
//    self.imageFromSource = [info objectForKey:UIImagePickerControllerOriginalImage];
//    
//}

@end
