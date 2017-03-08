//
//  MEHLoginViewController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/3/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEHLoginViewController;

@protocol MEHLoginViewControllerDelegate <NSObject>

- (void)didLoginSuccessfully: (MEHLoginViewController *)loginVC;

@optional
- (void)didDismissLoginScreen : (MEHLoginViewController *)loginVC;

@end

@interface MEHLoginViewController : UIViewController

+ (UINavigationController *)loginViewControllerInNavigationControllerWithDelegate : (id<MEHLoginViewControllerDelegate>)delegate;


@property (nonatomic, weak) id<MEHLoginViewControllerDelegate>delegate;


@end
