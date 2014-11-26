//
//  DHDraftsTableViewController.m
//  Appetizr
//
//  Created by dasdom on 06.01.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "DHDraftsTableViewController.h"
#import "DHDraftCell.h"

@interface DHDraftsTableViewController ()

@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) NSDateFormatter *draftDateFormatter;

@end

@implementation DHDraftsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.dataSource = [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivePath]];
    self.draftDateFormatter = [[NSDateFormatter alloc] init];
    self.draftDateFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.draftDateFormatter.timeStyle = NSDateFormatterMediumStyle;
    
    dhDebug(@"self.dataSource: %@", self.dataSource);
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
    static NSString *CellIdentifier = @"DraftCell";
    DHDraftCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSDictionary *draftDict = [self.dataSource objectAtIndex:indexPath.row];
    cell.dateLabel.text = [self.draftDateFormatter stringFromDate:[draftDict objectForKey:@"draftDate"]];
    cell.draftLabel.text = [draftDict objectForKey:@"postText"];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *mutableDataSource = [self.dataSource mutableCopy];
        [mutableDataSource removeObjectAtIndex:indexPath.row];
        self.dataSource = [mutableDataSource copy];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    NSDictionary *draftDict = [self.dataSource objectAtIndex:indexPath.row];
    [((UINavigationController*)self.presentingViewController).topViewController setValue:[draftDict objectForKey:@"postText"] forKey:@"draftText"];
    [((UINavigationController*)self.presentingViewController).topViewController setValue:[draftDict objectForKey:@"replyToId"] forKey:@"replyToId"];
    NSString *imagePath = [draftDict objectForKey:@"imagePath"];
    if (imagePath) {
        NSData *imageData = [NSData dataWithContentsOfFile:imagePath];
        [self.presentingViewController setValue:[UIImage imageWithData:imageData] forKey:@"postImage"];
        NSFileManager *defaultManager = [NSFileManager defaultManager];
        [defaultManager removeItemAtPath:imagePath error:nil];
    }
    NSMutableArray *mutableDataSource = [self.dataSource mutableCopy];
    [mutableDataSource removeObjectAtIndex:indexPath.row];
    [NSKeyedArchiver archiveRootObject:[mutableDataSource copy] toFile:[self archivePath]];
        
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (IBAction)cancelButtonTouched:(id)sender {
    [NSKeyedArchiver archiveRootObject:self.dataSource toFile:[self archivePath]];

    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (NSString*)archivePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:@"PostDrafts"];
}

@end
