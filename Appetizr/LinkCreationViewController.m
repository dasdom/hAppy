//
//  LinkCreationViewController.m
//  Appetizr
//
//  Created by dasdom on 24.03.13.
//  Copyright (c) 2013 dasdom. All rights reserved.
//

#import "LinkCreationViewController.h"
#import "DHCreateStatusViewController.h"
#import "PRPAlertView.h"

@interface LinkCreationViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UITextField *linkTextTextField;
@property (nonatomic, strong) UITextField *urlTextField;
@end

@implementation LinkCreationViewController

- (id)init
{
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
    CGRect frame = self.navigationController.view.frame;
    frame.size.height = frame.size.height-self.navigationController.navigationBar.frame.size.height;
    UIView *contentView = [[UIView alloc] initWithFrame:frame];
    
    UIView *linkTextHostView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 30.0f, frame.size.width-20.0f, 35.0f)];
    [contentView addSubview:linkTextHostView];
    
    _linkTextTextField = [[UITextField alloc] initWithFrame:CGRectMake(5.0f, 5.0f, linkTextHostView.frame.size.width-10.0f, 35.0f)];
    _linkTextTextField.placeholder = NSLocalizedString(@"link text", nil);
//    _linkTextTextField.borderStyle = UITextBorderStyleBezel;
    _linkTextTextField.delegate = self;
    _linkTextTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _linkTextTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if (self.linkText) {
        _linkTextTextField.text = self.linkText;
    }
    [linkTextHostView addSubview:_linkTextTextField];
    
    UIView *urlHostView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 80.0f, frame.size.width-20.0f, 35.0f)];
    [contentView addSubview:urlHostView];

    _urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(5.0f, 5.0f, urlHostView.frame.size.width-10.0f, 25.0f)];
    _urlTextField.placeholder = NSLocalizedString(@"url", nil);
//    _urlTextField.borderStyle = UITextBorderStyleBezel;
    _urlTextField.delegate = self;
    _urlTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [urlHostView addSubview:_urlTextField];
    
    UIButton *okButton = [UIButton buttonWithType:UIButtonTypeCustom];
    okButton.frame = CGRectMake(10.0f, 130.0f, frame.size.width-20.0f, 40.0f);
    [okButton setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    [okButton addTarget:self action:@selector(okButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:okButton];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        contentView.backgroundColor = kDarkCellBackgroundColorDefault;
//        okButton.backgroundColor = kDarkCellBackgroundColorMarked;
//        okButton.titleLabel.textColor = kDarkTextColor;
//        linkTextHostView.backgroundColor = kDarkCellBackgroundColorMarked;
//        urlHostView.backgroundColor = kDarkCellBackgroundColorMarked;
//        self.linkTextTextField.textColor = kDarkTextColor;
//        self.urlTextField.textColor = kDarkTextColor;
//        self.navigationController.navigationBar.tintColor = kDarkMainColor;
        contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkCellBackgroundColor;
        okButton.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        okButton.titleLabel.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        linkTextHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        urlHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].darkMarkedCellBackgroundColor;
        self.linkTextTextField.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        self.urlTextField.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
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
        contentView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].cellBackgroundColor;
        okButton.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        okButton.titleLabel.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        linkTextHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        urlHostView.backgroundColor = [DHGlobalObjects sharedGlobalObjects].markedCellBackgroundColor;
        self.linkTextTextField.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        self.urlTextField.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
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
    self.view = contentView;
    
    self.title = NSLocalizedString(@"create link", nil);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSString *urlString = [[UIPasteboard generalPasteboard] string];
    if ([urlString rangeOfString:@"http"].location != NSNotFound || [urlString rangeOfString:@"www"].location != NSNotFound) {
        self.urlTextField.text = urlString;
    }
    
    [self.linkTextTextField becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"cancel", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancel:(UIBarButtonItem*)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)okButtonTouched:(UIButton*)sender {
    if (!self.linkTextTextField.text && [self.linkTextTextField.text isEqualToString:@""]) {
        [PRPAlertView showWithTitle:NSLocalizedString(@"link text missing", nil) message:NSLocalizedString(@"you have to provide a link text", nil) buttonTitle:NSLocalizedString(@"ok", nil)];
        return;
    } else if (!self.urlTextField.text && [self.urlTextField.text isEqualToString:@""]) {
        [PRPAlertView showWithTitle:NSLocalizedString(@"url missing", nil) message:NSLocalizedString(@"you have to provide a url", nil) buttonTitle:NSLocalizedString(@"ok", nil)];
        return;
    }
    NSDictionary *linkDictionary = @{@"linkText": self.linkTextTextField.text, @"url": self.urlTextField.text};
//    if ([self.presentingViewController respondsToSelector:@selector(addLink:)]) {
        [self.createStatusViewController addLink:linkDictionary];
//    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
