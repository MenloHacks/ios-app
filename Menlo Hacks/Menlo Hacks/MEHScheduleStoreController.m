//
//  ScheduleStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "MEHScheduleStoreController.h"

#import "MEHEvent.h"

@implementation MEHScheduleStoreController

+ (instancetype)sharedScheduleStoreController {
  static dispatch_once_t once;
  static MEHScheduleStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (void)getScheduleItems : (void (^)(NSArray<MEHEvent *> * results))completion {
//  PFQuery *query = [Event query];
//  query.cachePolicy = kPFCachePolicyNetworkElseCache;
//  [query orderByAscending:@"start_time"];
//  [query includeKey:@"location"];
//  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//      completion(objects);
//  }];
}



@end
