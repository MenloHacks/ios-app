//
//  MainEventDetailsStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "MainEventDetailsStoreController.h"

#import <Parse/Parse.h>

@interface MainEventDetailsStoreController()

@property (nonatomic, strong) PFObject *dateDetails;

@end

@implementation MainEventDetailsStoreController


+ (instancetype)sharedMainEventDetailsStoreController {
  static dispatch_once_t once;
  static MainEventDetailsStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (id)init {
  self = [super init];
  return self;
}

- (void)getDateDetailsFromServer : (void (^)())completion {
  PFQuery *query = [PFQuery queryWithClassName:@"MasterTiming"];
  [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
    _dateDetails = object;
    completion();
  }];
}

- (void)getEventStartTimeWithCompletion: (void (^)(NSDate * date))completion {
  if(_dateDetails) {
    completion(_dateDetails[@"startDate"]);
  }
  else {
    [self getDateDetailsFromServer:^{
      completion(_dateDetails[@"startDate"]);
    }];
  }
}

- (void)getEventEndTimeWithCompletion: (void (^)(NSDate * date))completion {
  if(_dateDetails) {
    completion(_dateDetails[@"endDate"]);
  }
  else {
    [self getDateDetailsFromServer:^{
      completion(_dateDetails[@"endDate"]);
    }];
  }
}

@end
