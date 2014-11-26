//
//  AuthenticationViewController.m
//  Appetizr
//
//  Created by dasdom on 05.04.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "PRPAlertView.h"
#import "PRPConnection.h"
#import "SSKeychain.h"
#import "DHAppDelegate.h"
#import "ADNLogin.h"
#import "DHKeys.h"

@interface AuthenticationViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) NSString *scope;
@end

@implementation AuthenticationViewController

- (id)init
{
    if ((self = [super init]))
    {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)loadView {
    CGRect frame = self.navigationController.view.frame;
    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height;
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    
    self.scope = @"stream write_post follow messages email update_profile files";
    NSString *scopeString = @"- create, upload, and view your App.net files\n- update your profile information\n- read your stream\n- send and receive private and public messages for you\n- create posts for you\n- see basic information about you\n- add or remove follows for you";
    
    UIView *userNameHostView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, frame.size.width-20.0f, 30.0f)];
    userNameHostView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:userNameHostView];
    
    _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(5.0f, 5.0f, userNameHostView.frame.size.width-10.0f, 20.0f)];
    _usernameTextField.placeholder = NSLocalizedString(@"username", nil);
    //    _linkTextTextField.borderStyle = UITextBorderStyleBezel;
    _usernameTextField.delegate = self;
    _usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _usernameTextField.returnKeyType = UIReturnKeyNext;
    _usernameTextField.backgroundColor = [UIColor clearColor];
    _usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [userNameHostView addSubview:_usernameTextField];
    
    UIView *passwordHostView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, CGRectGetMaxY(userNameHostView.frame)+10.0f, frame.size.width-20.0f, 30.0f)];
    passwordHostView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:passwordHostView];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(5.0f, 5.0f, userNameHostView.frame.size.width-10.0f, 20.0f)];
    _passwordTextField.placeholder = NSLocalizedString(@"password", nil);
    //    _urlTextField.borderStyle = UITextBorderStyleBezel;
    _passwordTextField.delegate = self;
    _passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.returnKeyType = UIReturnKeyJoin;
    _passwordTextField.backgroundColor = [UIColor clearColor];
    [passwordHostView addSubview:_passwordTextField];
    
    _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _okButton.frame = CGRectMake(10.0f, CGRectGetMaxY(passwordHostView.frame)+10.0f, frame.size.width-20.0f, 40.0f);
    [_okButton setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    [_okButton addTarget:self action:@selector(okButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    _okButton.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:_okButton];
    
    UIButton *loginViaPassport;
    loginViaPassport = [UIButton buttonWithType:UIButtonTypeCustom];
    loginViaPassport.frame = CGRectMake(10.0f, CGRectGetMaxY(_okButton.frame)+15.0f, frame.size.width-20.0f, 40.0f);
    [loginViaPassport setTitle:NSLocalizedString(@"or Login via Passport", nil) forState:UIControlStateNormal];
    [loginViaPassport addTarget:self action:@selector(loginViaPassportButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    loginViaPassport.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:loginViaPassport];
    
    if (![[ADNLogin sharedInstance] isLoginAvailable]) {
        loginViaPassport.hidden = YES;
    }
    
    NSDictionary *viewsDictionary = @{@"userNameHostView": userNameHostView, @"passwordHostView": passwordHostView, @"_okButton": _okButton, @"loginViaPassport": loginViaPassport};
    NSArray *verticalConstrains = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[userNameHostView(30)]-[passwordHostView(30)]-[_okButton(40)]-[loginViaPassport(40)]" options:0 metrics:nil views:viewsDictionary];
    [contentView addConstraints:verticalConstrains];
    
    NSArray *horizontalContrains1 = [NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[userNameHostView]-10-|" options:0 metrics:nil views:viewsDictionary];
    [contentView addConstraints:horizontalContrains1];

    NSArray *horizontalContrains2 = [NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[passwordHostView]-10-|" options:0 metrics:nil views:viewsDictionary];
    [contentView addConstraints:horizontalContrains2];

    NSArray *horizontalContrains3 = [NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_okButton]-10-|" options:0 metrics:nil views:viewsDictionary];
    [contentView addConstraints:horizontalContrains3];

    NSArray *horizontalContrains4 = [NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[loginViaPassport]-10-|" options:0 metrics:nil views:viewsDictionary];
    [contentView addConstraints:horizontalContrains4];
    
    
    UILabel *scopeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 200.0f, frame.size.width-20.0f, 180.0f)];
    scopeLabel.numberOfLines = 0;
    scopeLabel.font = [UIFont fontWithName:@"Avenir-Book" size:12.0f];
    scopeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"This application will have access to:\n%@", nil), scopeString];
    scopeLabel.backgroundColor = [UIColor clearColor];
    [contentView addSubview:scopeLabel];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
        contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        _okButton.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        _okButton.titleLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        loginViaPassport.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        loginViaPassport.titleLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        userNameHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        passwordHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        self.usernameTextField.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        self.passwordTextField.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            self.navigationController.navigationBar.barTintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
            self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        }
        else
        {
            self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
        }
        scopeLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
    } else {
        contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        _okButton.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        _okButton.titleLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        loginViaPassport.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        loginViaPassport.titleLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        userNameHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        passwordHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        self.usernameTextField.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        self.passwordTextField.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
        {
            self.navigationController.navigationBar.barTintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
            self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        }
        else
        {
            self.navigationController.navigationBar.tintColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
        }
        scopeLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
    }
    self.view = contentView;
    
    self.title = NSLocalizedString(@"authenticate", nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSString *accessToken = [SSKeychain passwordForService:@"de.dasdom.happy" account:[[NSUserDefaults standardUserDefaults] objectForKey:kUserNameDefaultKey]];
    if (accessToken) {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAuth:)];
        self.navigationItem.rightBarButtonItem = cancelBarButtonItem;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.usernameTextField]) {
        [self.passwordTextField becomeFirstResponder];
    } else if ([textField isEqual:self.passwordTextField]) {
        if ([self.passwordTextField.text isEqualToString:@""] || [self.usernameTextField.text isEqualToString:@""]) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Missing", nil) message:NSLocalizedString(@"You have to provide username and password.", nil) buttonTitle:NSLocalizedString(@"ok", nil)];
        }
        
        [self authorate];
    }
    return NO;
}

- (void)okButtonTouched:(UIButton*)sender {
    if ([self.usernameTextField.text length] < 1 || [self.passwordTextField.text length] < 1) {
        [PRPAlertView showWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please enter you username and password.", nil) buttonTitle:NSLocalizedString(@"OK", nil)];
        return;
    }
    sender.enabled = NO;
    [self authorate];
}

- (void)authorate {
    NSString *urlString = @"https://account.app.net/oauth/access_token";
    
    NSString *clientId = kClientId;
    NSString *passwordGrantSecret = kPasswordGrantSecret;
    
    NSString *postString = [NSString stringWithFormat:@"client_id=%@&password_grant_secret=%@&grant_type=password&username=%@&password=%@&scope=%@", clientId, passwordGrantSecret, self.usernameTextField.text,
//                            self.passwordTextField.text,
//                            [self.passwordTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                            (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self.passwordTextField.text, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8)),
                            self.scope];
    
    NSMutableURLRequest *authRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    authRequest.HTTPMethod = @"POST";
//    NSString *encodedPostString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)postString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    authRequest.HTTPBody = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    PRPConnection *authConnection = [PRPConnection connectionWithRequest:authRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:authRequest progress:^(DHConnection *connection) {} completion:^(DHConnection *connection, NSError *error) {
        NSDictionary *responseDict = [connection dictionaryFromDownloadedData];
        NSLog(@"responseDict: %@", responseDict);
        self.okButton.enabled = YES;
        if ([responseDict objectForKey:@"error"]) {
            NSString *errorMessage = [NSString stringWithFormat:@"%@\n(%@)", [responseDict objectForKey:@"error"], [responseDict objectForKey:@"error_slug"]];
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error", nil) message:errorMessage buttonTitle:NSLocalizedString(@"OK", nil)];
            return;
        }
        
        NSString *accessToken = [responseDict objectForKey:@"access_token"];
        
        if (accessToken) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults removeObjectForKey:kAccessTokenDefaultsKey];
            [userDefaults synchronize];
            
            NSString *urlString = [NSString stringWithFormat:@"%@%@%@?access_token=%@", kBaseURL, kUsersSubURL, kMeSubURL, accessToken];
            PRPConnection *dhConnection = [PRPConnection connectionWithURL:[NSURL URLWithString:urlString] progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//            [DHConnection connectionWithURL:[NSURL URLWithString:urlString] progress:^(DHConnection* connection){} completion:^(DHConnection *connection, NSError *error) {
                //                NSLog(@"connection.responseDictionary: %@", connection.responseDictionary);
                NSError *jsonError;
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:connection.downloadData options:kNilOptions error:&jsonError];
                dhDebug(@"responseDict: %@", responseDict);
                NSString *userName = [[responseDict objectForKey:@"data"] objectForKey:@"username"];
                
                [SSKeychain deletePasswordForService:@"de.dasdom.happy" account:userName];
                BOOL success = [SSKeychain setPassword:accessToken forService:@"de.dasdom.happy" account:userName];
                
                if (!success) {
                    [[[UIAlertView alloc] initWithTitle:@"Bad Error!" message:@"Please tell @dasdom that you have seen error 11 during login. Thanks!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                
                }
                NSArray *userArray = [userDefaults objectForKey:kUserArrayKey];
                
                if ((userArray && [userArray count] < 1) || ![userArray containsObject:userName]) {
                    
                    [userDefaults setObject:userName forKey:kUserNameDefaultKey];
                    
                    NSMutableArray *mutableUserArray;
                    if (!userArray || [userArray count] < 1) {
                        mutableUserArray = [NSMutableArray array];
                    } else {
                        mutableUserArray = [userArray mutableCopy];
                    }
                    
                    [mutableUserArray addObject:userName];
                    [userDefaults setObject:mutableUserArray forKey:kUserArrayKey];
                    
//                    NSMutableDictionary *userDefaultsDictionaryForCurrentUser = [NSMutableDictionary dictionary];
//                    [userDefaultsDictionaryForCurrentUser setObject:@"15.0f" forKey:kFontSize];
//                    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:NO] forKey:kIncludeDirecedPosts];
//                    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:NO] forKey:kDontLoadImages];
//                    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:NO] forKey:kDarkMode];
//                    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:YES] forKey:kStreamMarker];
//                    [userDefaultsDictionaryForCurrentUser setObject:[NSNumber numberWithBool:NO] forKey:kHideSeenThreads];
//                    [userDefaultsDictionaryForCurrentUser setObject:@"Avenir-Book" forKey:kFontName];
//                    
//                    [userDefaults setObject:userDefaultsDictionaryForCurrentUser forKey:userName];
//                    
//                    [userDefaults setBool:NO forKey:kIncludeDirecedPosts];
//                    [userDefaults setBool:NO forKey:kDontLoadImages];
//                    [userDefaults setBool:NO forKey:kDarkMode];
//                    [userDefaults setBool:YES forKey:kStreamMarker];
//                    [userDefaults setBool:NO forKey:kHideSeenThreads];
//                    [userDefaults setObject:@"15.0f" forKey:kFontSize];
//                    [userDefaults setObject:@"Avenir-Book" forKey:kFontName];
                    
                    success = [userDefaults synchronize];
                    if (!success) {
                        [[[UIAlertView alloc] initWithTitle:@"Bad Error!" message:@"Please tell @dasdom that you have seen error 22 during login. Thanks!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
                        
                    }
                }
                
                //                if (![currentUserName isEqualToString:userName]) {
                [self dismissViewControllerAnimated:YES completion:^{}];
                //                } else {
                //                    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
                //                    [webView removeFromSuperview];
                //                    [self loadLogin];
                //                }
            }];
            [dhConnection start];
            
        }
    }];
    [authConnection start];
}

- (void)cancelAuth:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)loginViaPassportButtonTouched:(UIButton*)sender {
    sender.enabled = NO;
//    NSArray *scopeArray = [self.scope componentsSeparatedByString:@" "];
//    dhDebug(@"scopeArray: %@", scopeArray);
    [[ADNLogin sharedInstance] login];
//    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
