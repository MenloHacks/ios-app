//
//  ScheduleStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask, RLMResults, MEHEvent;

@interface MEHScheduleStoreController : NSObject


+ (instancetype)sharedScheduleStoreController;

- (BFTask *)fetchScheduleItems;
- (BFTask *)events;



@end
