//
//  AnnouncementsStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/1/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "MEHAnnouncementsStoreController.h"

#import "MEHAnnouncement.h"

@implementation MEHAnnouncementsStoreController

+ (instancetype)sharedAnnouncementsStoreController {
  static dispatch_once_t once;
  static MEHAnnouncementsStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}



@end
