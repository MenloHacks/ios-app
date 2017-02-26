//
//  MainEventDetailsStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "MEHEventTimingStoreController.h"

#import <Bolts/Bolts.h>

#import "NSDate+Utilities.h"

#import "MEHHTTPSessionManager.h"

@interface MEHEventTimingStoreController()

@property (nonatomic, strong) NSDate *eventStartTimeDate;
@property (nonatomic, strong) NSDate *eventEndTimeDate;

@property (nonatomic, strong) NSDate *hackingStartTimeDate;
@property (nonatomic, strong) NSDate *hackingEndTimeDate;

@property (nonatomic) dispatch_semaphore_t fetchSemaphore;
@property (nonatomic) BOOL fetchInProgress;

@end


static NSString * kMEHEventStartTimeKey = @"com.menlohacks.eventStartTime";
static NSString * kMEHEventEndTimeKey = @"com.menlohacks.eventEndTime";
static NSString * kMEHHackingStartTimeKey = @"com.menlohacks.hackingStartTime";
static NSString * kMEHHackingEndTimeKey = @"com.menlohacks.hackingEndTime";


@implementation MEHEventTimingStoreController


+ (instancetype)sharedTimingStoreController {
  static dispatch_once_t once;
  static MEHEventTimingStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        [self setCachedTimes];
        [self fetchTimesFromServer];
    }
    return self;
}

- (void)setCachedTimes {
    NSUserDefaults *standardDefalts = [NSUserDefaults standardUserDefaults];
    self.eventStartTimeDate = [standardDefalts objectForKey:kMEHEventStartTimeKey];
    self.eventEndTimeDate = [standardDefalts objectForKey:kMEHEventEndTimeKey];
    
    self.hackingStartTimeDate = [standardDefalts objectForKey:kMEHHackingEndTimeKey];
    self.hackingEndTimeDate = [standardDefalts objectForKey:kMEHHackingEndTimeKey];
}

- (BFTask *)eventStartTime {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
//    if(self.fetchInProgress) {
//        dispatch_semaphore_wait(_fetchSemaphore, DISPATCH_TIME_FOREVER);
//    }
    if(self.eventStartTimeDate) {
        [completionSource setResult:self.eventStartTimeDate];
    } else {
        [[self fetchTimesFromServer]continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            if(t.error) {
                [completionSource setError:t.error];
            } else {
                [completionSource setResult:self.eventStartTimeDate];
            }
            
            return nil;
        }];
    }

    return completionSource.task;
}

- (BFTask *)eventEndTime {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
//    if(self.fetchInProgress) {
//        dispatch_semaphore_wait(_fetchSemaphore, DISPATCH_TIME_FOREVER);
//    }
    if(self.eventEndTimeDate) {
        [completionSource setResult:self.eventEndTimeDate];
    } else {
        [[self fetchTimesFromServer]continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            if(t.error) {
                [completionSource setError:t.error];
            } else {
                [completionSource setResult:self.eventEndTimeDate];
            }
            
            return nil;
        }];
    }
    
    return completionSource.task;
}

- (BFTask *)hackingStartTime {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
//    if(self.fetchInProgress) {
//        dispatch_semaphore_wait(_fetchSemaphore, DISPATCH_TIME_FOREVER);
//    }
    if(self.hackingStartTimeDate) {
        [completionSource setResult:self.hackingStartTimeDate];
    } else {
        [[self fetchTimesFromServer]continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            if(t.error) {
                [completionSource setError:t.error];
            } else {
                [completionSource setResult:self.hackingStartTimeDate];
            }
            
            return nil;
        }];
    }
    
    return completionSource.task;
}

- (BFTask *)hackingEndTime {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
//    if(self.fetchInProgress) {
//        dispatch_semaphore_wait(_fetchSemaphore, DISPATCH_TIME_FOREVER);
//    }
    if(self.hackingEndTimeDate) {
        [completionSource setResult:self.hackingEndTimeDate];
    } else {
        [[self fetchTimesFromServer]continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            if(t.error) {
                [completionSource setError:t.error];
            } else {
                [completionSource setResult:self.hackingEndTimeDate];
            }
            
            return nil;
        }];
    }
    
    return completionSource.task;
}

- (BFTask *)fetchTimesFromServer {
    self.fetchInProgress = YES;
    self.fetchSemaphore = dispatch_semaphore_create(0);
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"times" parameters:nil]continueWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        
        if (task.error) {
            self.fetchInProgress = NO;
            dispatch_semaphore_signal(self.fetchSemaphore);
            return task;
        }
        else if(task.result) {
            
            NSDictionary *timesDictionary = task.result[@"data"];
            self.eventStartTimeDate = [NSDate dateFromISOString:timesDictionary[@"event_start_time"]];
            self.eventEndTimeDate = [NSDate dateFromISOString:timesDictionary[@"event_end_time"]];
            self.hackingStartTimeDate = [NSDate dateFromISOString:timesDictionary[@"hacking_start_time"]];
            self.hackingEndTimeDate = [NSDate dateFromISOString:timesDictionary[@"hacking_end_time"]];
            
            self.fetchInProgress = NO;
            dispatch_semaphore_signal(self.fetchSemaphore);
            
            //Save the times on a background thread. We don't need this to get the times and IO is time consuming.
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
                [standardDefaults setObject:self.eventStartTimeDate forKey:kMEHEventStartTimeKey];
                [standardDefaults setObject:self.eventEndTimeDate forKey:kMEHEventEndTimeKey];
                [standardDefaults setObject:self.hackingStartTimeDate forKey:kMEHHackingStartTimeKey];
                [standardDefaults setObject:self.hackingEndTimeDate forKey:kMEHHackingEndTimeKey];
                [standardDefaults synchronize];
            });
            
            return nil;
        }
        return nil;
    }];
}


@end
