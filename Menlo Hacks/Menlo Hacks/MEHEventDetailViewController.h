//
//  EventDetailViewController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/24/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEHEvent;

@interface MEHEventDetailViewController : UIViewController

@property (nonatomic, strong) MEHEvent *event;

@end
