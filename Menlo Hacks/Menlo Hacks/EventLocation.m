//
//  EventLocation.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/24/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "EventLocation.h"

@implementation EventLocation

@dynamic map_image;
@dynamic location_name;

+ (NSString *)parseClassName {
  return @"EventLocation";
}

+ (void)load {
  [self registerSubclass];
}

@end
