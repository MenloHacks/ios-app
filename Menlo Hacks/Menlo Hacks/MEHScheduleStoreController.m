//
//  ScheduleStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "MEHScheduleStoreController.h"

#import <Bolts/Bolts.h>
#import "RLMRealm+MenloHacks.h"
#import "NSDate+Utilities.h"

#import "MEHEvent.h"
#import "MEHEventTimingStoreController.h"
#import "MEHHTTPSessionManager.h"

@implementation MEHScheduleStoreController

+ (instancetype)sharedScheduleStoreController {
  static dispatch_once_t once;
  static MEHScheduleStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (BFTask *)fetchScheduleItems {
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"events" parameters:nil]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        if(t.result) {
            NSArray *data = t.result[@"data"];
            RLMRealm *realm = [RLMRealm defaultRealm];
            __block NSMutableArray *eventIDs = [NSMutableArray arrayWithCapacity:data.count];
            //Precondition: server sorted by start time––>which is true.
            return [[realm meh_TransactionWithBlock:^{
                for (NSDictionary *eventDictionary in data) {
                    MEHEvent *event = [MEHEvent eventFromDictionary:eventDictionary];
                    [eventIDs addObject:event.serverID];
                    [realm addOrUpdateObject:event];
                }
            }]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                RLMResults *objectsToDelete = [MEHEvent objectsWhere:@"NOT (serverID IN %@)", eventIDs];
                return [realm meh_TransactionWithBlock:^{
                    [realm deleteObjects:objectsToDelete];
                }];
            }];

        }
        return nil;
    }];
    
}
- (BFTask *)didReceiveNotification: (NSDictionary*)notification {
    if(notification) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        return [realm meh_TransactionWithBlock:^{
            MEHEvent *event = [MEHEvent eventFromDictionary:notification];
            [realm addOrUpdateObject:event];
        }];
    }
    return nil;

}

- (BFTask *)events {
    __block NSDate *eventStartTime;
    return [[[MEHEventTimingStoreController sharedTimingStoreController]eventStartTime]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        eventStartTime = t.result;
        return [[[MEHEventTimingStoreController sharedTimingStoreController]eventEndTime]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
            NSDate *eventEndTime = t.result;
            NSInteger numberOfDays = [NSDate numberOfDaysBetween:eventStartTime and:eventEndTime];
            NSMutableArray *eventsArray = [NSMutableArray arrayWithCapacity:numberOfDays];
            
             NSDateComponents *startComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay |
                                             NSCalendarUnitMonth |
                                             NSCalendarUnitYear
                                                                            fromDate:eventStartTime];
            
            
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            [calendar setTimeZone:[NSTimeZone systemTimeZone]];
            NSDate *currentDate = [calendar dateFromComponents:startComponents];
            
            for (int i = 0; i < numberOfDays; i++) {
                NSDate *tomorrow = [currentDate add24Hours];
                RLMResults *results = [[MEHEvent objectsWhere:@"startTime > %@ AND startTime < %@", currentDate, tomorrow]sortedResultsUsingKeyPath:@"startTime" ascending:YES];
                if(results.count > 0) {
                    [eventsArray addObject:results];
                }
                currentDate = tomorrow;
            }
            return [BFTask taskWithResult:eventsArray];
            
        
            
        }];
    }];
}


@end
