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
        NSMutableArray *announcementIDs = [NSMutableArray arrayWithCapacity:announcements.count];
        __block NSDate *firstAnnouncementDate;
        __block NSDate *lastAnnouncementDate;
        return [[realm meh_TransactionWithBlock:^{
            int i = 0;
            for (NSDictionary *announcementDictionary in announcements) {
                MEHAnnouncement *announcement = [MEHAnnouncement announcementFromDictionary:announcementDictionary];
                [announcementIDs addObject:announcement.serverID];
                if (i==0) {
                    firstAnnouncementDate = announcement.time;
                } else if (i==announcements.count - 1) {
                    lastAnnouncementDate = announcement.time;
                }
                i++;
                [realm addOrUpdateObject:announcement];
            }
        }]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
            //Note still a bug with first and last objects.
            RLMResults *objectsToDelete;
            if(start == 0) {
                objectsToDelete = [MEHAnnouncement objectsWhere:@"NOT (serverID IN %@) AND time > %@", announcementIDs, lastAnnouncementDate];
            } else if (announcements.count < count) {
                objectsToDelete = [MEHAnnouncement objectsWhere:@"NOT (serverID IN %@) AND time < %@", announcementIDs, firstAnnouncementDate];
            } else {
                objectsToDelete = [MEHAnnouncement objectsWhere:@"NOT (serverID IN %@) AND time > %@ AND time < %@", announcementIDs, lastAnnouncementDate, firstAnnouncementDate];
            }

            return [realm meh_TransactionWithBlock:^{
                [realm deleteObjects:objectsToDelete];
            }];
        }];;
        

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
    return [[MEHAnnouncement allObjects]sortedResultsUsingProperty:@"time" ascending:NO];
}



@end
