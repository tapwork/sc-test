//
//  SCLoginViewController.m
//  SoundcloudTest
//
//  Created by Christian Menschel on 25.08.13.
//  Copyright (c) 2013 tapwork. All rights reserved.
//

#import "SCLoginViewController.h"
#import "SCApiManager.h"

static CGFloat kTopOffset = 80.0;
static CGSize kInputFieldSize = {280.0,30.0} ;
static CGSize kSendButtonSize = {100.0,30.0} ;


@interface SCLoginViewController ()

@end

@implementation SCLoginViewController
{
    __weak UITextField  *_emailTextField;
    __weak UITextField  *_pwTextField;
    __weak UIButton     *_sendButton;
    __weak UIButton     *_cancelButton;
    __weak UIActivityIndicatorView *_activityView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITextField* emailTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    emailTextField.placeholder = NSLocalizedString(@"eMail", @"");
    emailTextField.clearButtonMode = UITextFieldViewModeAlways;
    emailTextField.borderStyle = UITextBorderStyleRoundedRect;
    emailTextField.delegate = self;
    emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTextField.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:emailTextField];
    _emailTextField = emailTextField;
    
    
    UITextField* passTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    
    passTextField.placeholder = NSLocalizedString(@"password", @"");
    passTextField.clearButtonMode = UITextFieldViewModeAlways;
    passTextField.clearsOnBeginEditing = YES;
    passTextField.borderStyle = UITextBorderStyleRoundedRect;
    passTextField.delegate = self;
    passTextField.secureTextEntry = YES;
    passTextField.returnKeyType = UIReturnKeyGo;
    passTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    passTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passTextField.placeholder = NSLocalizedString(@"Your password", @"");
    [self.view addSubview:passTextField];
    _pwTextField = passTextField;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [sendButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    [sendButton setTitle:NSLocalizedString(@"Login", @"") forState:UIControlStateNormal];
    sendButton.enabled = NO;
    [self.view addSubview:sendButton];
    _sendButton = sendButton;
    
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.hidesWhenStopped = YES;
    [self.view addSubview:activityView];
    _activityView = activityView;
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat leftOffset = floorf((self.view.bounds.size.width - kInputFieldSize.width) / 2);
    _emailTextField.frame = CGRectMake(leftOffset,
                                       kTopOffset,
                                       kInputFieldSize.width,
                                       kInputFieldSize.height);
    _pwTextField.frame = CGRectMake(leftOffset,
                                    CGRectGetMaxY(_emailTextField.frame)+5,
                                    kInputFieldSize.width,
                                    kInputFieldSize.height);
    
    
    

    _sendButton.frame = CGRectMake(CGRectGetMaxX(_pwTextField.frame)-kSendButtonSize.width,
                                   CGRectGetMaxY(_pwTextField.frame)+15,
                                   kSendButtonSize.width,
                                   kSendButtonSize.height);
    
    _cancelButton.frame = CGRectMake(_pwTextField.frame.origin.x,
                                   CGRectGetMaxY(_pwTextField.frame)+15,
                                   kSendButtonSize.width,
                                   kSendButtonSize.height);

    
    _activityView.center = self.view.center;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
    if (_emailTextField.text.length > 0 &&
        _pwTextField.text.length > 0)
    {
        _sendButton.enabled = YES;
    }
    else
    {
        _sendButton.enabled = NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([_emailTextField isEqual:textField])
    {
        [_pwTextField becomeFirstResponder];
    }
    else if ([_pwTextField isEqual:textField])
    {
        [self login:nil];
        [textField resignFirstResponder];
    }
    return NO;
}

#pragma mark - API
- (void)login:(id)sender
{
    [_activityView startAnimating];
    [[SCApiManager sharedInstance]
     loginWithUsername:_emailTextField.text
     password:_pwTextField.text
     completion:^(BOOL success) {
         
         [_activityView stopAnimating];
         
         if ([self.delegate respondsToSelector:@selector(loginViewController:didLogin:)])
         {
             [self.delegate loginViewController:self didLogin:success];
         }
     }];
}

- (void)cancelLogin:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(loginViewControllerDidCancel:)])
    {
        [self.delegate loginViewControllerDidCancel:self];
    }
}


@end
