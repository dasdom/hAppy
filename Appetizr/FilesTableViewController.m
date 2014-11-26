//
//  FilesTableViewController.m
//  Appetizr
//
//  Created by dasdom on 20.04.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "FilesTableViewController.h"
#import "SSKeychain.h"
#import "PRPConnection.h"
#import "PRPAlertView.h"
#import "DHWebViewController.h"

@interface FilesTableViewController ()
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSString *maxId;
@property (nonatomic, strong) NSString *minId;
@property (nonatomic, strong) NSCache *imageCache;
@end

@implementation FilesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
//
//    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@/users/me/files?access_token=%@", kBaseURL, accessToken];
//    
//    NSMutableURLRequest *filesRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithAccessToken]];
//    [filesRequest setHTTPMethod:@"GET"];
//    [filesRequest setValue:@"Accept-Encoding" forHTTPHeaderField:@"gzip"];
//    
//    __weak FilesTableViewController *weakSelf = self;
//    DHConnection *filesConnection = [DHConnection connectionWithRequest:filesRequest progress:^(DHConnection *connection){} completion:^(DHConnection *connection, NSError *error) {
//        
//        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
////        NSLog(@"responseDict: %@", responseDict);
//        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
//        NSLog(@"metaDict: %@", metaDict);
//        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
//            [DHAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:error.localizedDescription cancelButtonTitle:@"OK" cancelBlock:^{
//            } otherButtonTitle:@"Retry" otherBlock:^{
//
//            }];
//            return;
//        }
//        
//        self.maxId = [metaDict objectForKey:@"max_id"];
//        self.minId = [metaDict objectForKey:@"min_id"];
//        
//        weakSelf.dataSource = [responseDict objectForKey:@"data"];
//        [self.tableView reloadData];
//    }];
//    [filesConnection start];
    
    [self loadFileList];
    
    self.imageCache = [[NSCache alloc] init];
    
    self.title = NSLocalizedString(@"files", nil);
}

- (void)loadFileList {
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    
    NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@/users/me/files?count=200&access_token=%@", kBaseURL, accessToken];
    
    NSMutableURLRequest *filesRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithAccessToken]];
    [filesRequest setHTTPMethod:@"GET"];
    [filesRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    __weak FilesTableViewController *weakSelf = self;
    PRPConnection *filesConnection = [PRPConnection connectionWithRequest:filesRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:filesRequest progress:^(DHConnection *connection){} completion:^(DHConnection *connection, NSError *error) {
    
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
//        NSLog(@"responseDict: %@", responseDict);
        NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
        dhDebug(@"metaDict: %@", metaDict);
        if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:[metaDict objectForKey:@"error_message"] buttonTitle:@"OK"];
            return;
        }
        
        self.maxId = [metaDict objectForKey:@"max_id"];
        self.minId = [metaDict objectForKey:@"min_id"];
        
        weakSelf.dataSource = [responseDict objectForKey:@"data"];
        [self.tableView reloadData];
    }];
    [filesConnection start];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *fileDict = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [fileDict objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f MB", [[fileDict objectForKey:@"size"] floatValue]/1000000.0f];
    cell.imageView.image = nil;
    
    if ([[fileDict objectForKey:@"kind"] isEqualToString:@"image"]) {
        dhDebug(@"image_thumb_200s: %@", [[fileDict objectForKey:@"derived_files"] objectForKey:@"image_thumb_200s"]);
        NSDictionary *thumbDict = [[fileDict objectForKey:@"derived_files"] objectForKey:@"image_thumb_200s"];
        
        __weak FilesTableViewController *weakSelf = self;
        dispatch_queue_t avatarDownloaderQueue = dispatch_queue_create("de.dasdom.avatarDownloader", NULL);
        dispatch_async(avatarDownloaderQueue, ^{
            NSString *imageUrlString = [thumbDict objectForKey:@"url"];
//            CGFloat width = [[fileDict objectForKey:@"width"] floatValue];
//            //            dhDebug(@"width: %f", width);
            NSString *imageKey = [[imageUrlString componentsSeparatedByString:@"/"] lastObject];
//            NSCache *imageCache = [(DHAppDelegate*)[[UIApplication sharedApplication] delegate] avatarCache];
            UIImage *image = [self.imageCache objectForKey:imageKey];
            if (!image) {
                image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrlString]]];
                
            }
            dispatch_sync(dispatch_get_main_queue(), ^{
                UITableViewCell *asyncCell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
//                if ([asyncCell isKindOfClass:([DHPostCell class])] &&
//                    numberOfCells == [weakSelf.userStreamArray count]) {
                    [[asyncCell imageView] setImage:image];
                [asyncCell setNeedsLayout];
//                }
            });
        });

    }
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];

        NSDictionary *fileDict = [self.dataSource objectAtIndex:indexPath.row];

        NSString *urlStringWithAccessToken = [NSString stringWithFormat:@"%@/files/%@?access_token=%@", kBaseURL, [fileDict objectForKey:@"id"], accessToken];
        
        NSMutableURLRequest *deleteRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStringWithAccessToken]];
        [deleteRequest setHTTPMethod:@"DELETE"];

        PRPConnection *deleteConnection = [PRPConnection connectionWithRequest:deleteRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//        [DHConnection connectionWithRequest:deleteRequest progress:^(DHConnection *connection) {} completion:^(DHConnection *connection, NSError *error) {
        
            NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
            dhDebug(@"responseDict: %@", responseDict);
            NSDictionary *metaDict = [responseDict objectForKey:@"meta"];
            dhDebug(@"metaDict: %@", metaDict);
            if (error || [[metaDict objectForKey:@"code"] integerValue] != 200) {
                [PRPAlertView showWithTitle:NSLocalizedString(@"Error occurred", nil) message:[metaDict objectForKey:@"error_message"] buttonTitle:@"OK"];
                return;
            }
            [self loadFileList];
        }];
        [deleteConnection start];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
    DHWebViewController *detailViewController = [storyBoard instantiateViewControllerWithIdentifier:@"WebViewController"];
    NSDictionary *fileDict = [self.dataSource objectAtIndex:indexPath.row];
    detailViewController.linkString = [fileDict objectForKey:@"url"];
    [self.navigationController pushViewController:detailViewController animated:YES];
     
}

@end
