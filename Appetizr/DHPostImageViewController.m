//
//  DHPostImageViewController.m
//  Appetizr
//
//  Created by dasdom on 03.02.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "DHPostImageViewController.h"
#import "PRPConnection.h"

@interface DHPostImageViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *postImageView;
@property (nonatomic, strong) UIProgressView *downloadProgressView;
@property (nonatomic, strong) UIScrollView *postImageScrollView;
@end

@implementation DHPostImageViewController

- (id)initWithPostImageURL:(NSString*)postImageURL {
    if ((self = [super init])) {
        self.postImageURL = postImageURL;
    }
    return self;
}

- (void)loadView {
//    CGRect frame = [[UIScreen mainScreen] applicationFrame];
//    NSLog(@"frame: %@", NSStringFromCGRect(frame));
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        frame.size.height = frame.size.height - 44.0f;
//        frame.size.width = frame.size.width - 320.0f;
//    } else {
//        frame.size.height = frame.size.height - 44.0f;
//    }
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }

    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    dhDebug(@"frame: %@", NSStringFromCGRect(frame));

    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    contentView.backgroundColor = [UIColor blackColor];
    
//    CGRect scrollViewFrame = contentView.bounds;
//    scrollViewFrame.origin.y = self.navigationController.navigationBar.frame.size.height;
//    scrollViewFrame.size.height = scrollViewFrame.size.height - self.navigationController.navigationBar.frame.size.height;
    
    CGRect scrollViewFrame = contentView.bounds;
    
    _postImageScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    _postImageScrollView.delegate = self;
    _postImageScrollView.minimumZoomScale = 1.0f;
    _postImageScrollView.maximumZoomScale = 3.0f;
    _postImageScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    CGRect imageFrame = frame;
    imageFrame.origin.y = 0.0f;
    imageFrame.size.height = imageFrame.size.height - self.navigationController.navigationBar.frame.size.height-20.0f;
    
    _postImageScrollView.contentSize = imageFrame.size;

    _postImageView = [[UIImageView alloc] initWithFrame:imageFrame];
    _postImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _postImageView.contentMode = UIViewContentModeScaleAspectFit;
//    _postImageView.backgroundColor = [UIColor redColor];
    if (self.postImage) {
//        CGSize postImageSize = self.postImage.size;
//        CGRect postImageViewFrame = _postImageView.frame;
//        if (postImageSize.width > 0.0f && postImageSize.height > 0.0f) {
//            if ((postImageSize.height / postImageSize.width) < (postImageViewFrame.size.height / postImageViewFrame.size.width)) {
//                postImageViewFrame.size.height = postImageViewFrame.size.width * postImageSize.height / postImageSize.width;
//            } else {
//                postImageViewFrame.size.width = postImageViewFrame.size.height * postImageSize.width / postImageSize.height;
//            }
//            postImageViewFrame.origin.x = (contentView.frame.size.width - postImageViewFrame.size.width)/2.0f;
//            postImageViewFrame.origin.y = (contentView.frame.size.height - postImageViewFrame.size.height)/2.0f;
//            _postImageView.frame = postImageViewFrame;
//        }
        _postImageView.image = self.postImage;
    }
    [_postImageScrollView addSubview:_postImageView];
    
    [contentView addSubview:_postImageScrollView];
    
    _downloadProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    CGRect progressViewFrame = _downloadProgressView.frame;
    progressViewFrame.origin.x = 0.0f;
    progressViewFrame.origin.y = 64.0f;
    progressViewFrame.size.width = frame.size.width;
    _downloadProgressView.frame = progressViewFrame;
    _downloadProgressView.progress = 0.0f;
    [contentView addSubview:_downloadProgressView];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
        contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        _downloadProgressView.progressTintColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
    } else {
        contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        _downloadProgressView.progressTintColor = [DHGlobalObjects sharedGlobalObjects].textColor;
    }
    
    __weak DHPostImageViewController *weakSelf = self;
//    dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("de.dasdom.postImageDownloader", NULL);
//    dispatch_async(imgDownloaderQueue, ^{
//        weakSelf.postImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.postImageURL]]];
//        CGSize postImageSize = weakSelf.postImage.size;
//        CGRect postImageViewFrame = _postImageView.frame;
//        if (postImageSize.width > 0.0f && postImageSize.height > 0.0f) {
//            if ((postImageSize.height / postImageSize.width) < (postImageViewFrame.size.height / postImageViewFrame.size.width)) {
//                postImageViewFrame.size.height = postImageViewFrame.size.width * postImageSize.height / postImageSize.width;
//            } else {
//                postImageViewFrame.size.width = postImageViewFrame.size.height * postImageSize.width / postImageSize.height;
//            }
//            postImageViewFrame.origin.x = (contentView.frame.size.width - postImageViewFrame.size.width)/2.0f;
//            postImageViewFrame.origin.y = (contentView.frame.size.height - postImageViewFrame.size.height)/2.0f;
//            _postImageView.frame = postImageViewFrame;
//        }
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            [_postImageView setImage:weakSelf.postImage];
//        });
//    });
    
    NSMutableURLRequest *imageRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.postImageURL]];
    [imageRequest setHTTPMethod:@"GET"];
    [imageRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    PRPConnection *imageConnection = [PRPConnection connectionWithRequest:imageRequest progressBlock:^(PRPConnection *connection) {
        self.downloadProgressView.progress = (CGFloat)[connection.downloadData length]/[[connection.responseHeaders objectForKey:@"Content-Length"] floatValue];

    } completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:imageRequest progress:^(DHConnection *connection){
//        self.downloadProgressView.progress = (CGFloat)[connection.downloadData length]/[[connection.responseHeaders objectForKey:@"Content-Length"] floatValue];
//    } completion:^(DHConnection *connection, NSError *error) {
        weakSelf.postImage = [[UIImage alloc] initWithData:connection.downloadData];
//        CGSize postImageSize = weakSelf.postImage.size;
//        CGRect postImageViewFrame = contentView.bounds;
//        if (postImageSize.width > 0.0f && postImageSize.height > 0.0f) {
//            if ((postImageSize.height / postImageSize.width) < (postImageViewFrame.size.height / postImageViewFrame.size.width)) {
//                postImageViewFrame.size.height = postImageViewFrame.size.width * postImageSize.height / postImageSize.width;
//            } else {
//                postImageViewFrame.size.width = postImageViewFrame.size.height * postImageSize.width / postImageSize.height;
//            }
//            postImageViewFrame.origin.x = (contentView.frame.size.width - postImageViewFrame.size.width)/2.0f;
//            postImageViewFrame.origin.y = (contentView.frame.size.height - postImageViewFrame.size.height)/2.0f;
//            _postImageView.frame = postImageViewFrame;
//        }
        [_postImageView setImage:weakSelf.postImage];
        self.downloadProgressView.alpha = 0.0f;
    }];
    [imageConnection start];
    
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRightHappend:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRightGestureRecognizer];
    
    UIBarButtonItem *exportButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveImage:)];
    self.navigationItem.rightBarButtonItem = exportButton;
    
//    CGRect scrollViewFrame = self.view.bounds;
//    scrollViewFrame.origin.y = self.navigationController.navigationBar.frame.size.height;
//    scrollViewFrame.size.height = scrollViewFrame.size.height - self.navigationController.navigationBar.frame.size.height;
//    _postImageScrollView.frame = scrollViewFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.postImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    dhDebug(@"self.postImageView.frame: %@", NSStringFromCGRect(self.postImageView.frame));
    dhDebug(@"scrollView.frame: %@", NSStringFromCGRect(scrollView.frame));
    dhDebug(@"scrollView.contentSize: %@", NSStringFromCGSize(scrollView.contentSize));
//    CGRect postImageViewFrame = self.postImageView.frame;
//    postImageViewFrame.origin.x = MAX((scrollView.frame.size.width - postImageViewFrame.size.width)/2.0f,0.0f);
//    postImageViewFrame.origin.y = MAX((scrollView.frame.size.height - postImageViewFrame.size.height)/2.0f,0.0f);
//    self.postImageView.frame = postImageViewFrame;
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    CGSize postImageSize = self.postImage.size;
//    CGRect postImageViewFrame = self.view.frame;
//    if (postImageSize.width > 0.0f && postImageSize.height > 0.0f) {
//        if ((postImageSize.height / postImageSize.width) < (postImageViewFrame.size.height / postImageViewFrame.size.width)) {
//            postImageViewFrame.size.height = postImageViewFrame.size.width * postImageSize.height / postImageSize.width;
//        } else {
//            postImageViewFrame.size.width = postImageViewFrame.size.height * postImageSize.width / postImageSize.height;
//        }
//        postImageViewFrame.origin.x = (self.view.frame.size.width - postImageViewFrame.size.width)/2.0f;
//        postImageViewFrame.origin.y = (self.view.frame.size.height - postImageViewFrame.size.height)/2.0f;
//        _postImageView.frame = postImageViewFrame;
//    }
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x < -60.0f) {
        [self swipeRightHappend:nil];
    }
}

- (void)swipeRightHappend:(UISwipeGestureRecognizer*)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveImage:(UIBarButtonItem*)sender {
    UIImageWriteToSavedPhotosAlbum(self.postImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        // Show error message...
        
    }
    else  // No errors
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Image has been saved to your camera roll.", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
    }
}


@end
