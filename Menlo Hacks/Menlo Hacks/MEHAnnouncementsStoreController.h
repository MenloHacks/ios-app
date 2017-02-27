//
//  AnnouncementsStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/1/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask, RLMResults;

@interface MEHAnnouncementsStoreController : NSObject

+ (instancetype)sharedAnnouncementsStoreController;
- (BFTask *)fetchAnnouncementsWithStart : (NSInteger)start andCount : (NSInteger)count;
- (RLMResults *)announcements;


@end
