//
//  MEHLoginViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/3/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHLoginViewController.h"

#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"

#import "AutolayoutHelper.h"
#import <AFNetworking/AFNetworking.h>
#import <Bolts/Bolts.h>
#import "SCLAlertView.h"


#import "MEHBottomBorderTextField.h"
#import "MEHUserStoreController.h"

@interface MEHLoginViewController () <UITextFieldDelegate>


@property (nonatomic, strong) UILabel *welcomeLabel;

@property (nonatomic, strong) MEHBottomBorderTextField *usernameField;
@property (nonatomic, strong) MEHBottomBorderTextField *passwordField;

@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *passwordLabel;

@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) UIImageView *backgroundImageView;


@end

@implementation MEHLoginViewController


- (void)dismissSelf : (id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(didDismissLoginScreen:)]) {
            [self.delegate didDismissLoginScreen:self];
        }
    }];
}

+ (UINavigationController *)loginViewControllerInNavigationControllerWithDelegate : (id<MEHLoginViewControllerDelegate>)delegate{
    MEHLoginViewController *loginVC = [[MEHLoginViewController alloc]init];
    loginVC.delegate = delegate;
    
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:loginVC];
    
    navigationController.navigationBar.tintColor = [UIColor menloHacksPurple];
    navigationController.navigationBar.topItem.titleView = [[UIImageView alloc]initWithImage:
                                                     [UIImage imageNamed:@"menlohacks_nav"]];
    navigationController.navigationBar.translucent = NO;

    
    
    return navigationController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
    [self addConstraints];
    
    
    // Do any additional setup after loading the view.
}

- (void)createViews {
    
    if(self.presentingViewController) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                             target:self
                                                                             action:@selector(dismissSelf:)];
        self.navigationItem.leftBarButtonItems = @[item];
    }
    
    self.backgroundImageView = [UIImageView new];
    self.backgroundImageView.image = [UIImage imageNamed:@"launch_background"];
    
    UITapGestureRecognizer *dismissKeyboardRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard:)];
    [self.backgroundImageView addGestureRecognizer:dismissKeyboardRecognizer];
    self.backgroundImageView.userInteractionEnabled = YES;
 
    self.welcomeLabel = [UILabel new];
    self.welcomeLabel.textColor = [UIColor whiteColor];
    
    self.welcomeLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0];
    self.welcomeLabel.text = @"Welcome to MenloHacks II";
    
    self.usernameLabel = [UILabel new];
    self.usernameLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
    self.usernameLabel.text = @"Email";
    self.usernameLabel.textColor = [UIColor whiteColor];
    
    self.passwordLabel = [UILabel new];
    self.passwordLabel.textColor = [UIColor whiteColor];
    self.passwordLabel.text = @"Password";
    self.passwordField.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
    
    self.usernameField = [[MEHBottomBorderTextField alloc]initWithBorderColor:[UIColor whiteColor] borderWidth:1.0];
    self.usernameField.textColor = [UIColor whiteColor];
    self.usernameField.tintColor = [UIColor whiteColor];
    self.usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    self.usernameField.delegate = self;
    self.usernameField.returnKeyType = UIReturnKeyNext;
    self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.passwordField = [[MEHBottomBorderTextField alloc]initWithBorderColor:[UIColor whiteColor] borderWidth:1.0];
    self.passwordField.textColor = [UIColor whiteColor];
    self.passwordField.tintColor = [UIColor whiteColor];
    self.passwordField.secureTextEntry = YES;
    self.passwordField.delegate = self;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    
    self.nextButton = [UIButton new];
    [self.nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.nextButton.layer.borderWidth = 1.0f;
    self.nextButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.nextButton.layer.cornerRadius = 10.0f;
    
    [self.nextButton setTitle:@"Login" forState:UIControlStateNormal];
    self.nextButton.titleLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
    self.nextButton.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.nextButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchDown];
    
    
}

- (void)addConstraints {
    
    [AutolayoutHelper configureView:self.view fillWithSubView:self.backgroundImageView];
    
    [AutolayoutHelper configureView:self.view
                           subViews:NSDictionaryOfVariableBindings(_welcomeLabel, _usernameField, _usernameLabel, _passwordLabel, _passwordField, _nextButton)
                        constraints:@[@"V:|-30-[_welcomeLabel]-20-[_usernameLabel]-[_usernameField]-20-[_passwordLabel]-[_passwordField]-20-[_nextButton]",
                                      @"X:_welcomeLabel.centerX == superview.centerX",
                                      @"H:|-[_usernameField]-|",
                                      @"X:_usernameField.left == _usernameLabel.left",
                                      @"X:_passwordLabel.left == _usernameLabel.left",
                                      @"X:_passwordField.left == _usernameField.left",
                                      @"X:_passwordField.width == _usernameField.width",
                                      @"X:_nextButton.centerX == superview.centerX"]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dismissKeyboard : (id)sender {
    [self.usernameField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField == self.passwordField) {
        [self login:nil];
    }
    return YES;
}

- (void)login : (id)sender {
    SCLAlertView *alertView = [[SCLAlertView alloc]initWithNewWindow];
    [alertView showWaiting:@"Signing in" subTitle:nil closeButtonTitle:nil duration:0];
    

    
    

    [[[MEHUserStoreController sharedUserStoreController]loginWithUsername:self.usernameField.text password:self.passwordField.text]continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView hideView];
        });
        if(!t.error) {
            if(self.delegate) {
                [self.delegate didLoginSuccessfully:self];
            }
        }
        return nil;
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
