//
//  Event.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "Event.h"

@implementation Event

@dynamic time;
@dynamic location;
@dynamic eventDescription;

+ (NSString *)parseClassName {
  return @"Event";
}

+ (void)load {
  [self registerSubclass];
}

@end
