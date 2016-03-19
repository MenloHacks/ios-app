//
//  Map.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/2/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "Map.h"

@implementation Map

@dynamic caption;
@dynamic image;


+ (NSString *)parseClassName {
  return @"Map";
}

+ (void)load {
  [self registerSubclass];
}

@end
