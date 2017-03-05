//
//  UIViewController+Extensions.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/31/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "UIViewController+Extensions.h"

@implementation UIViewController (Extensions)

- (void)displayContentController:(UIViewController *)content {
  [self addChildViewController:content];
  content.view.frame = [[UIScreen mainScreen] bounds];
  [self.view addSubview:content.view];
  [content didMoveToParentViewController:self];
}

- (void)removeContentViewController : (UIViewController *)content {
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

@end
