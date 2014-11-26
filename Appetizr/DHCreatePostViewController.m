//
//  DHCreatePostViewController.m
//  Appetizr
//
//  Created by dasdom on 16.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHCreatePostViewController.h"
#import "DHConnection.h"

@interface DHCreatePostViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *postTextView;
@property (weak, nonatomic) IBOutlet UILabel *letterCount;
@end

@implementation DHCreatePostViewController
@synthesize postTextView;
@synthesize letterCount;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.letterCount.text = @"";
}

- (void)viewDidUnload
{
    [self setPostTextView:nil];
    [self setLetterCount:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *postString = textView.text;
    self.letterCount.text = [NSString stringWithFormat:@"%d", 256-[postString length]];
    [self.letterCount setNeedsDisplay];
}

- (IBAction)sendPost:(UIBarButtonItem *)sender {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kAccessTokenDefaultsKey];
    NSString *urlString = [NSString stringWithFormat:@"%@posts?access_token=%@", kBaseURL, accessToken];
    
    NSMutableURLRequest *postRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [postRequest setHTTPMethod:@"POST"];
    
    NSString *postString = [NSString stringWithFormat:@"text=%@", self.postTextView.text];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [postRequest setHTTPBody:postData];
    
    DHConnection *dhConnection = [DHConnection connectionWithRequest:postRequest progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
        NSLog(@"error: %@", error);
        if (error) {
            
        }
        NSDictionary *resposeDict = [NSJSONSerialization JSONObjectWithData:connection.downloadData options:kNilOptions error:nil];
        NSLog(@"resposeDict: %@", resposeDict);
        [self dismissViewControllerAnimated:YES completion:^{
    
        }];
    }];
    [dhConnection start];

}

@end
