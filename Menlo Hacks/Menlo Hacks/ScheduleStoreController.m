//
//  ScheduleStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "ScheduleStoreController.h"

#import <Parse/Parse.h>
#import "Event.h"

@implementation ScheduleStoreController

+ (instancetype)sharedScheduleStoreController {
  static dispatch_once_t once;
  static ScheduleStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (void)getScheduleItems : (void (^)(NSArray<Event *> * results))completion {
  PFQuery *query = [Event query];
  [query orderByAscending:@"time"];
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    completion(objects);
  }];
}



@end
