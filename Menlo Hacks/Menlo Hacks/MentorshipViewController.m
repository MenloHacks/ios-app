//
//  MentorshipViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/31/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "MentorshipViewController.h"

#import <Smooch/Smooch.h>
#import "UIViewController+Extensions.h"

@implementation MentorshipViewController

-(void)viewDidLoad {
  UIViewController *smoochVC = [Smooch newConversationViewController];
  
  [self displayContentController:smoochVC];
}


@end
