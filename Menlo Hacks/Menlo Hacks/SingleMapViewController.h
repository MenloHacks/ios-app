//
//  SingleMapViewController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/3/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEHLocation;

@interface SingleMapViewController : UIViewController

-(void)configureFromMap: (MEHLocation *)map;
@property (nonatomic) NSUInteger index;

@end
