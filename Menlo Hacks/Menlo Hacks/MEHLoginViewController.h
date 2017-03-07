//
//  MEHLoginViewController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/3/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MEHLoginViewControllerDelegate <NSObject>

- (void)didLoginSuccessfully;

@end

@interface MEHLoginViewController : UIViewController




@property (nonatomic, weak) id<MEHLoginViewControllerDelegate>delegate;


@end
