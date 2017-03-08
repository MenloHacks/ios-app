//
//  MEHCheckInViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/1/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHCheckInViewController.h"

#import <Bolts/Bolts.h>
#import "SCLAlertView.h"

#import "AutolayoutHelper.h"
#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"
#import "UIViewController+Extensions.h"

#import "MEHLoginViewController.h"
#import "MEHUser.h"
#import "MEHUserStoreController.h"

@import PassKit;

@interface MEHCheckInViewController () <MEHLoginViewControllerDelegate>

@property (nonatomic, strong) UILabel *welcomeLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) PKAddPassButton *addButton;

@property (nonatomic, strong) MEHLoginViewController *loginVC;


@end

@implementation MEHCheckInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor menloHacksPurple];
    
    self.parentViewController.navigationItem.rightBarButtonItems = @[];
    
    [self createViews];
    if(![[MEHUserStoreController sharedUserStoreController]isUserLoggedIn]) {
        self.loginVC = [[MEHLoginViewController alloc]init];
        self.loginVC.delegate = self;
        [self displayContentController:self.loginVC];
    } else {
        [self configureView];
    }
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(![[MEHUserStoreController sharedUserStoreController]isUserLoggedIn]) {
        if(!self.loginVC) {
            self.loginVC = [[MEHLoginViewController alloc]init];
            self.loginVC.delegate = self;
            [self displayContentController:self.loginVC];
        }
    } else {
        if(self.loginVC) {
            [self configureView];
            [self removeContentViewController:self.loginVC];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.rightBarButtonItems = @[];
}

- (void)createViews {
    self.welcomeLabel = [UILabel new];
    self.welcomeLabel.textColor = [UIColor whiteColor];
    self.welcomeLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0];
    
    self.descriptionLabel = [UILabel new];
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleBody]size:0];
    self.descriptionLabel.text = @"Please find a volunteer and show them your ticket.";
    
    self.addButton = [[PKAddPassButton alloc]initWithAddPassButtonStyle:PKAddPassButtonStyleBlack];
    [self.addButton addTarget:self action:@selector(getPassPressed:) forControlEvents:UIControlEventTouchDown];
    

    [AutolayoutHelper configureView:self.view
                           subViews:NSDictionaryOfVariableBindings(_welcomeLabel, _descriptionLabel, _addButton)
                        constraints:@[@"H:|-[_welcomeLabel]",
                                      @"X:_addButton.centerX == superview.centerX",
                                      @"H:|-[_descriptionLabel]|",
                                      @"V:|-30-[_welcomeLabel]-30-[_addButton]-20-[_descriptionLabel]"]];
    
}

- (void)configureView {
    NSString *username = [[MEHUserStoreController sharedUserStoreController]loggedInUserID];
    MEHUser *user = [MEHUser objectForPrimaryKey:username];
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@", user.name];
}

- (void)didLoginSuccessfully:(MEHLoginViewController *)loginVC {
    self.loginVC = nil;
    [self removeContentViewController:loginVC];
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPassPressed : (id)sender {
    SCLAlertView *alertView = [[SCLAlertView alloc]initWithNewWindow];
    [alertView showWaiting:@"Fetching" subTitle:nil closeButtonTitle:nil duration:0];
    
    [[[MEHUserStoreController sharedUserStoreController]getPass]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView hideView];
        });
        if ([PKAddPassesViewController canAddPasses]) {
            PKPass *pass = [[PKPass alloc] initWithData:t.result error:nil];
            PKAddPassesViewController *passVC = [[[PKAddPassesViewController alloc] init] initWithPass:pass];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:passVC animated:YES completion:nil];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                SCLAlertView *alertView = [[SCLAlertView alloc]initWithNewWindow];
                [alertView showError:@"Error" subTitle:@"This device does not support passbook." closeButtonTitle:@"Ok" duration:0];
            });

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
