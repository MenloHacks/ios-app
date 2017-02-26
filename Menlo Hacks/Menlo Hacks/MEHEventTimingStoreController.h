//
//  MainEventDetailsStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask;

@interface MEHEventTimingStoreController : NSObject

+ (instancetype)sharedTimingStoreController;

- (BFTask *)eventStartTime;
- (BFTask *)eventEndTime;
- (BFTask *)hackingStartTime;
- (BFTask *)hackingEndTime;


@end
