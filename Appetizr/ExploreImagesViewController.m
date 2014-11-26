//
//  ExploreImagesViewController.m
//  Appetizr
//
//  Created by dasdom on 09.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "ExploreImagesViewController.h"
#import "PostImageCell.h"

#define kCellWidth 320.0f

@interface ExploreImagesViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation ExploreImagesViewController

- (void)loadView {
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height;
    
    UICollectionViewFlowLayout *collectionViewFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] collectionViewLayout:collectionViewFlowLayout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    [collectionView registerClass:([PostImageCell class]) forCellWithReuseIdentifier:@"PostImageCell"];
    
    self.collectionView = collectionView;
    
    self.title = NSLocalizedString(@"photos", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imageStreamArray count];
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PostImageCell" forIndexPath:indexPath];
    
    NSDictionary *postDict = [self.imageStreamArray objectAtIndex:indexPath.row];
       
    NSArray *annotationsArray = [postDict objectForKey:@"annotations"];
    NSDictionary *imageAnnotationDict;
    for (NSDictionary *annotationDict in annotationsArray) {
        if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.oembed"] && [[[annotationDict objectForKey:@"value"] objectForKey:@"type"] isEqualToString:@"photo"]) {
            imageAnnotationDict = annotationDict;
        }
    }
    
    cell.postImageView.image = nil;
    [cell.loadingActivityIndicatorView startAnimating];
    
    if (imageAnnotationDict) {
        NSString *urlKey = @"url";
        NSString *heightKey = @"height";
        NSString *widthKey = @"width";
        
        NSDictionary *valueDict = [imageAnnotationDict objectForKey:@"value"];
        CGRect postImageFrame = cell.postImageView.frame;
        postImageFrame.size.height = (kCellWidth * [[valueDict objectForKey:heightKey] floatValue] / [[valueDict objectForKey:widthKey] floatValue]);
        //            dhDebug(@"postImageFrame: %@", NSStringFromCGRect(postImageFrame));
        cell.postImageView.frame = postImageFrame;
        
        dispatch_queue_t imgDownloaderQueue = dispatch_queue_create("de.dasdom.imageDownloader", NULL);
        dispatch_async(imgDownloaderQueue, ^{
            NSString *avatarUrlString = [valueDict objectForKey:urlKey];
//            UIImage *postImage = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]]];
            
            UIImage *postImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarUrlString]] scale:kCellWidth/[[valueDict objectForKey:widthKey] floatValue]];
            postImage = [UIImage imageWithData:UIImageJPEGRepresentation(postImage, 0.1f)];

            dispatch_sync(dispatch_get_main_queue(), ^{
                id asyncCell = [collectionView cellForItemAtIndexPath:indexPath];
                if ([asyncCell isKindOfClass:([PostImageCell class])]) {
                    [[asyncCell postImageView] setImage:postImage];
                    [[asyncCell loadingActivityIndicatorView] stopAnimating];
                }
            });
        });
        
        NSString *postText = [postDict objectForKey:@"text"];
        cell.postLabel.text = postText;
        CGSize postLabelSize = [postText sizeWithFont:cell.postLabel.font constrainedToSize:CGSizeMake(cell.postLabel.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//        CGRect postLabelFrame = cell.postLabel.frame;
//        postLabelFrame.size.height = postLabelSize.height;
//        postLabelFrame.origin.y = 10.0f;
//        cell.postLabel.frame = postLabelFrame;

        CGRect postLabelHostFrame = cell.labelHostView.frame;
//        postLabelHostFrame.size.height = MIN(postLabelSize.height+30.0f, cell.frame.size.height);
        postLabelHostFrame.size.height = postLabelSize.height+30.0f;
        postLabelHostFrame.origin.y = MAX(cell.frame.size.height - postLabelSize.height - 30.0f, 0.0f);
//        postLabelHostFrame.origin.y = cell.frame.size.height - postLabelSize.height - 30.0f;
        cell.labelHostView.frame = postLabelHostFrame;
        
        cell.labelHostView.hidden = NO;
    }

    if ([cell.gestureRecognizers count] < 1) {
        UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHappend:)];
        leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        [cell addGestureRecognizer:leftSwipeRecognizer];

        UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHappend:)];
        rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [cell addGestureRecognizer:rightSwipeRecognizer];
        
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHappend:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [cell addGestureRecognizer:doubleTapRecognizer];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PostImageCell *cell = (PostImageCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.labelHostView.hidden = !cell.labelHostView.hidden;
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *postDict = [self.imageStreamArray objectAtIndex:indexPath.row];
    NSArray *annotationsArray = [postDict objectForKey:@"annotations"];
    NSDictionary *imageAnnotationDict;
    for (NSDictionary *annotationDict in annotationsArray) {
        if ([[annotationDict objectForKey:@"type"] isEqualToString:@"net.app.core.oembed"] && [[[annotationDict objectForKey:@"value"] objectForKey:@"type"] isEqualToString:@"photo"]) {
            imageAnnotationDict = annotationDict;
        }
    }
    
    
    if (imageAnnotationDict) {
//        NSString *urlKey = @"url";
        NSString *heightKey = @"height";
        NSString *widthKey = @"width";
        
        NSDictionary *valueDict = [imageAnnotationDict objectForKey:@"value"];
        return CGSizeMake(kCellWidth, (kCellWidth * [[valueDict objectForKey:heightKey] floatValue] / [[valueDict objectForKey:widthKey] floatValue]));
    } else {
        return CGSizeZero;
    }
            
}

- (void)leftSwipeHappend:(UISwipeGestureRecognizer*)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(PostImageCell*)sender.view];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:MIN(indexPath.row+1, [self.imageStreamArray count]-1) inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (void)rightSwipeHappend:(UISwipeGestureRecognizer*)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(PostImageCell*)sender.view];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:MAX(indexPath.row-1, 0) inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
}

- (void)doubleTapHappend:(UITapGestureRecognizer*)sender {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(PostImageCell*)sender.view];
    CGPoint locationInView = [sender locationInView:sender.view];
    if (locationInView.x < kCellWidth/2.0f) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:MAX(indexPath.row-1, 0) inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    } else {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:MIN(indexPath.row+1, [self.imageStreamArray count]-1) inSection:indexPath.section] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    }
}

@end
