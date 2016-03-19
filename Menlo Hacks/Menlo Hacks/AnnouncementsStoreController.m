//
//  AnnouncementsStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/1/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "AnnouncementsStoreController.h"

#import <Parse/Parse.h>
#import "Announcement.h"

@implementation AnnouncementsStoreController

+ (instancetype)sharedAnnouncementsStoreController {
  static dispatch_once_t once;
  static AnnouncementsStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (void)getAnnouncements : (void (^)(NSArray<Announcement *> * results))completion {
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fireTime <= %@ AND armed == %@", [NSDate date],
                            [NSNumber numberWithBool:YES]];
  PFQuery *query = [Announcement queryWithPredicate:predicate];
  query.cachePolicy = kPFCachePolicyNetworkElseCache;
  [query orderByDescending:@"fireTime"];
  [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
    completion(objects);
  }];
}

@end
