//
//  Announcement.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/1/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "Announcement.h"

@implementation Announcement


@dynamic messageContents;
@dynamic fireTime;

+ (NSString *)parseClassName {
  return @"Announcement";
}

+ (void)load {
  [self registerSubclass];
}

@end
