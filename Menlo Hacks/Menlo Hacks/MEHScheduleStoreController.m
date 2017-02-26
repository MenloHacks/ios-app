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
            return [[realm meh_TransactionWithBlock:^{
                for (NSDictionary *eventDictionary in data) {
                    MEHEvent *event = [MEHEvent eventFromDictionary:eventDictionary];
                    [realm addOrUpdateObject:event];
                }
            }]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return nil;
            }];

        }
        return nil;
    }];
    
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
            NSDate *currentDate = [calendar dateFromComponents:startComponents];
            
            for (int i = 0; i < numberOfDays; i++) {
                NSDate *tomorrow = [currentDate add24Hours];
                RLMResults *results = [MEHEvent objectsWhere:@"startTime > %@ AND startTime < %@", currentDate, tomorrow];
                [eventsArray addObject:results];
                currentDate = tomorrow;
            }
            return [BFTask taskWithResult:eventsArray];
            
        
            
        }];
    }];
}


@end
