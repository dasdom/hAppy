//
//  DHMetaDataTableViewController.m
//  Appetizr
//
//  Created by Dominik Hauser on 26.10.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHMetaDataTableViewController.h"
#import "DHProfileTableViewController.h"
#import "DHWebViewController.h"
#import "DHHashtagTableViewController.h"
//#import "DHGlobalObjects.h"

enum METADATA_SECTIONS {
    METADATA_SECTION_MENTIONS = 0,
    METADATA_SECTION_LINKS,
    METADATA_SECTION_HASH_TAGS,
    METADATA_NUM_OF_SECTIONS,
    } METADATA_SECTIONS;

@interface DHMetaDataTableViewController ()

@end

@implementation DHMetaDataTableViewController

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return METADATA_NUM_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch (section) {
        case METADATA_SECTION_MENTIONS:
            numberOfRows = [self.mentionsArray count];
            break;
        case METADATA_SECTION_LINKS:
            numberOfRows = [self.linksArray count];
            break;
        case METADATA_SECTION_HASH_TAGS:
            numberOfRows = [self.hashTagArray count];
            break;
        default:
            NSAssert1(false, @"unsupported section %d", section);
            break;
    }
    return numberOfRows;
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 20.0f)];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.backgroundColor = [UIColor grayColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    switch (section) {
        case METADATA_SECTION_MENTIONS:
        {
            NSString *category = [self.mentionsArray count] == 1 ? @"mention" : @"mentions";
            headerLabel.text = [NSString stringWithFormat:@"%d %@", [self.mentionsArray count], category];
        }
            break;
        case METADATA_SECTION_LINKS:
        {
            NSString *category = [self.linksArray count] == 1 ? @"link" : @"links";
            headerLabel.text = [NSString stringWithFormat:@"%d %@", [self.linksArray count], category];
        }
            break;
        case METADATA_SECTION_HASH_TAGS:
        {
            NSString *category = [self.hashTagArray count] == 1 ? @"hash tag" : @"hash tags";
            headerLabel.text = [NSString stringWithFormat:@"%d %@", [self.hashTagArray count], category];
        }
            break;
            
        default:
            break;
    }
    return headerLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MetaDataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case METADATA_SECTION_MENTIONS:
        {
            NSDictionary *mentionsDict = [self.mentionsArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [mentionsDict objectForKey:@"name"];
            cell.textLabel.textColor = kLightMentionColor;
        }
            break;
        case METADATA_SECTION_LINKS:
        {
            NSDictionary *linksDict = [self.linksArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [linksDict objectForKey:@"url"];
            cell.textLabel.textColor = kLightLinkColor;
        }
            break;
        case METADATA_SECTION_HASH_TAGS:
        {
            NSDictionary *hashTagDict = [self.hashTagArray objectAtIndex:indexPath.row];
            cell.textLabel.text = [hashTagDict objectForKey:@"name"];
            cell.textLabel.textColor = kLightHashTagColor;
            UILongPressGestureRecognizer *muteHashtagRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(muteHashtag:)];
            [cell addGestureRecognizer:muteHashtagRecognizer];
        }
            break;
        default:
            NSAssert1(false, @"unsupported section %d", indexPath.section);
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case METADATA_SECTION_MENTIONS:
        {
            NSDictionary *mentionsDict = [self.mentionsArray objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"ShowProfile" sender:[mentionsDict objectForKey:@"id"]];
        }
            break;
        case METADATA_SECTION_LINKS:
        {
            NSDictionary *linksDict = [self.linksArray objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"ShowWeb" sender:[linksDict objectForKey:@"url"]];
        }
            break;
        case METADATA_SECTION_HASH_TAGS:
        {
            NSDictionary *hashTagDict = [self.hashTagArray objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"ShowHashTag" sender:[hashTagDict objectForKey:@"name"]];
        }
            break;
        default:
            NSAssert1(false, @"unsupported section %d", indexPath.section);
            break;
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowProfile"]) {
        DHProfileTableViewController *profileTableViewController = segue.destinationViewController;
        profileTableViewController.userId = (NSString*)sender;
        profileTableViewController.hidesBottomBarWhenPushed = YES;
    } else if ([segue.identifier isEqualToString:@"ShowWeb"]) {
        DHWebViewController *webViewController = segue.destinationViewController;
        webViewController.linkString = (NSString*)sender;
    } else if ([segue.identifier isEqualToString:@"ShowHashTag"]) {
        DHHashtagTableViewController *hashtagViewController = segue.destinationViewController;
        hashtagViewController.hashTagString = (NSString*)sender;
    }
}

- (void)muteHashtag:(UILongPressGestureRecognizer*)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender.view];
    NSDictionary *hashTagDict = [self.hashTagArray objectAtIndex:indexPath.row];
    
    NSMutableSet *mutableMutedHashtagSet = [[DHGlobalObjects sharedGlobalObjects].mutedHashtagSet mutableCopy];
    [mutableMutedHashtagSet addObject:[hashTagDict objectForKey:@"name"]];
    [DHGlobalObjects sharedGlobalObjects].mutedHashtagSet = [mutableMutedHashtagSet copy];
    
    NSString *announcement = [NSString stringWithFormat:@"hashtag %@ muted", [hashTagDict objectForKey:@"name"]];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, announcement);
}

@end
