//
//  MEHMentorshipViewController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <UIKit/UIKit.h>


@class BFTask;

@interface MEHMentorshipViewController : UIViewController

@property (nonatomic, copy, nonnull) BFTask * (^fetchFromServer)();
@property (nonatomic) BOOL requiresLogin;
@property (nonatomic) NSArray <NSPredicate *> *predicates;
@property (nonatomic, nullable) NSArray *predicateLabels;




@end
