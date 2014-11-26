//
//  InstapaperLoginViewController.m
//  Appetizr
//
//  Created by dasdom on 11.02.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "InstapaperLoginViewController.h"
#import "PRPConnection.h"
#import "Base64.h"
#import "SSKeychain.h"
#import "PRPAlertView.h"

@interface InstapaperLoginViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *userNameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UIButton *loginButton;
@end

@implementation InstapaperLoginViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }
    return self;
}

- (void)loadView {
    UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    
    _userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 30.0f, contentView.frame.size.width-40.0f, 30.0f)];
    _userNameTextField.delegate = self;
    _userNameTextField.borderStyle = UITextBorderStyleLine;
    _userNameTextField.placeholder = @"username";
    [contentView addSubview:_userNameTextField];
    
    _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 80.0f, contentView.frame.size.width-40.0f, 30.0f)];
    _passwordTextField.secureTextEntry = YES;
    _passwordTextField.delegate = self;
    _passwordTextField.borderStyle = UITextBorderStyleLine;
    _passwordTextField.placeholder = @"password (if you have one)";
    [contentView addSubview:_passwordTextField];
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _loginButton.frame = CGRectMake(20.0f, 130.0f, contentView.frame.size.width-40.0f, 40.0f);
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        _loginButton.backgroundColor = kDarkCellBackgroundColorDefault;
//        [_loginButton setTintColor:kDarkTintColor];
//        contentView.backgroundColor = kDarkMainColor;
        _loginButton.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        [_loginButton setTintColor:[DHGlobalObjects sharedGlobalObjects].darkTextColor];
        contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMainColor;
    } else {
        _loginButton.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        [_loginButton setTintColor:[DHGlobalObjects sharedGlobalObjects].textColor];
        contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].mainColor;
    }
    [_loginButton addTarget:self action:@selector(connectWithInstapaper:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:_loginButton];
    
    self.view = contentView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"instapaper";
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:kInstapaperUserNameKey];
    if (userName) {
        self.userNameTextField.hidden = YES;
        self.passwordTextField.hidden = YES;
        [self.loginButton setTitle:@"disconnect" forState:UIControlStateNormal];
    } else {
        self.userNameTextField.hidden = NO;
        self.passwordTextField.hidden = NO;
        [self.loginButton setTitle:@"connect" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)connectWithInstapaper:(UIButton*)sender {
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:kInstapaperUserNameKey];
    if (userName) {
        NSString *password = [SSKeychain passwordForService:kInstapaperServiceName account:userName];
        if (password) {
            [SSKeychain deletePasswordForService:kInstapaperServiceName account:userName];
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kInstapaperUserNameKey];
        return;
    }
    
    if ([self.userNameTextField.text isEqualToString:@""]) {
        [PRPAlertView showWithTitle:NSLocalizedString(@"User name empty", nil) message:NSLocalizedString(@"You have to provide a user name.", nil) buttonTitle:@"Ok"];
        return;
    }
    
    NSString *basicAuthString = [NSString stringWithFormat:@"%@:%@", self.userNameTextField.text, self.passwordTextField.text];
    NSString *encodedAuthString = [Base64 encode:[basicAuthString dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *authString = [NSString stringWithFormat:@"Basic %@", encodedAuthString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kInstapaperAuthURL]];
    [urlRequest setValue:authString forHTTPHeaderField:@"Authorization"];
    
    PRPConnection *dhConnection = [PRPConnection connectionWithRequest:urlRequest progressBlock:^(PRPConnection *connection) {} completionBlock:^(PRPConnection *connection, NSError *error) {
//    [DHConnection connectionWithRequest:urlRequest progress:^(DHConnection *connection) {} completion:^(DHConnection *connection, NSError *error) {
        dhDebug(@"statusCode: %d", connection.statusCode);
        if (connection.statusCode != 200) {
            [PRPAlertView showWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Could not connect to your instapaper account.", nil) buttonTitle:@"Ok"];
            return;
        }
        
        if (![self.passwordTextField.text isEqualToString:@""]) {
            [SSKeychain setPassword:self.passwordTextField.text forService:kInstapaperServiceName account:self.userNameTextField.text];
        }
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text forKey:kInstapaperUserNameKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [dhConnection start];
}

@end
