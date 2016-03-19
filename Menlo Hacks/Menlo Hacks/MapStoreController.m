//
//  MapStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/2/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "MapStoreController.h"

#import "Map.h"

@implementation MapStoreController

+ (instancetype)sharedMapStoreController {
  static dispatch_once_t once;
  static MapStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (void)getMaps : (void (^)(NSArray<Map *> * results))completion {
  PFQuery *query = [Map query];
  query.cachePolicy = kPFCachePolicyNetworkElseCache;
  [query orderByAscending:@"order"];
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    completion(objects);
  }];
}


@end
