//
//  MEHCheckInViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/1/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHCheckInViewController.h"

#import "UIColor+ColorPalette.h"
#import "UIViewController+Extensions.h"

#import "MEHLoginViewController.h"
#import "MEHUserStoreController.h"

@interface MEHCheckInViewController () <MEHLoginViewControllerDelegate>

@property (nonatomic, strong) MEHLoginViewController *loginVC;

@end

@implementation MEHCheckInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor menloHacksPurple];
    if(![[MEHUserStoreController sharedUserStoreController]isUserLoggedIn]) {
        self.loginVC = [[MEHLoginViewController alloc]init];
        self.loginVC.delegate = self;
        [self displayContentController:self.loginVC];
    }
    // Do any additional setup after loading the view.
}

- (void)didLoginSuccessfully {
    [self removeContentViewController:self.loginVC];
    self.loginVC = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
