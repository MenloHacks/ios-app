//
//  AnnouncementsStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/1/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "MEHAnnouncementsStoreController.h"

#import <Bolts/Bolts.h>
#import "RLMRealm+MenloHacks.h"

#import "MEHAnnouncement.h"
#import "MEHHTTPSessionManager.h"

@implementation MEHAnnouncementsStoreController

+ (instancetype)sharedAnnouncementsStoreController {
  static dispatch_once_t once;
  static MEHAnnouncementsStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (BFTask *)fetchAnnouncementsWithStart : (NSInteger)start andCount : (NSInteger)count {
    NSDictionary *parameters = @{@"start" : @(start),
                                 @"count" : @(count)};
    
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"announcements" parameters:parameters]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        NSArray *announcements = t.result[@"data"];
        RLMRealm *realm = [RLMRealm defaultRealm];
        return [realm meh_TransactionWithBlock:^{
            for (NSDictionary *announcementDictionary in announcements) {
                MEHAnnouncement *announcement = [MEHAnnouncement announcementFromDictionary:announcementDictionary];
                [realm addOrUpdateObject:announcement];
            }
        }];
        

    }];
    
}

- (RLMResults *)announcements {
    return [[MEHAnnouncement allObjects]sortedResultsUsingProperty:@"time" ascending:NO];
}



@end
