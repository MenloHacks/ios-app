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
#import "NSDate+Utilities.h"

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

- (BFTask *)fetchAnnouncements {
    
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"announcements" parameters:nil]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        NSArray *announcements = t.result[@"data"];
        RLMRealm *realm = [RLMRealm defaultRealm];
        __block NSMutableArray<NSString *> *announcementIDs = [NSMutableArray arrayWithCapacity:announcements.count];
        return [[realm meh_TransactionWithBlock:^{
            for (NSDictionary *announcementDictionary in announcements) {
                MEHAnnouncement *announcement = [MEHAnnouncement announcementFromDictionary:announcementDictionary];
                [announcementIDs addObject:announcement.serverID];
                [realm addOrUpdateObject:announcement];
            }
        }]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
            RLMResults *objectsToDelete = [MEHAnnouncement objectsWhere:@"NOT (serverID IN %@)", announcementIDs];
            return [realm meh_TransactionWithBlock:^{
                [realm deleteObjects:objectsToDelete];
            }];
        }];


        

    }];
    
}

- (BFTask *)didReceiveNotification: (NSDictionary *)notificationBody {
    if (notificationBody) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        return [realm meh_TransactionWithBlock:^{
            MEHAnnouncement *announcement = [MEHAnnouncement announcementFromDictionary:notificationBody];
            [realm addOrUpdateObject:announcement];
        }];
    }
    return nil;
}

- (RLMResults *)announcements {
    return [[MEHAnnouncement allObjects]sortedResultsUsingKeyPath:@"time" ascending:NO];
}



@end
