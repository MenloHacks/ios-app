//
//  MEHMentorshipStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask;

extern NSString * kMEHQueueCategory;
extern NSString *kMEHClaimedCategory;


@interface MEHMentorshipStoreController : NSObject

+ (instancetype)sharedMentorshipStoreController;

- (BFTask *)fetchQueue;

@end
