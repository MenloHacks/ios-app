//
//  ScheduleStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Event;

@interface ScheduleStoreController : NSObject

+ (instancetype)sharedScheduleStoreController;

- (void)getScheduleItems : (void (^)(NSArray<Event *> * results))completion;

@end
