//
//  MapStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/2/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "MEHMapStoreController.h"

#import <Bolts/Bolts.h>

#import "MEHHTTPSessionManager.h"
#import "MEHLocation.h"
#import "RLMRealm+MenloHacks.h"

@implementation MEHMapStoreController

+ (instancetype)sharedMapStoreController {
  static dispatch_once_t once;
  static MEHMapStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (BFTask *)fetchMaps {
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"maps" parameters:nil]
            continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                NSArray *maps = t.result[@"data"];
                RLMRealm *realm = [RLMRealm defaultRealm];
                return [realm meh_TransactionWithBlock:^{
                    for (NSDictionary *mapDictionary in maps) {
                        MEHLocation *location = [MEHLocation locationFromDictionary:mapDictionary];
                        [realm addOrUpdateObject:location];
                    }
                }];

    }];
    
}

- (RLMResults *)maps {
    return [[MEHLocation objectsWhere:@"isPrimary = 1"]sortedResultsUsingProperty:@"rank" ascending:YES];
}



@end
