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

typedef enum : NSUInteger {
    MEHMentorActionClaim=0,
    MEHMentorActionReopen=1,
    MEHMentorActionClose=2,
} MEHMentorAction;

@interface MEHMentorshipStoreController : NSObject

+ (instancetype)sharedMentorshipStoreController;

- (BFTask *)fetchQueue;
- (BFTask *)fetchClaimedQueue;
- (BFTask *)fetchUserQueue;

- (BFTask *)createTicket : (NSString *)description location : (NSString *)location contact : (NSString *)contact;

- (BFTask *)performAction: (MEHMentorAction)action onTicketWithIdentifier : (NSString *)serverID;
+ (NSString *)verbForAction : (MEHMentorAction)action;



@end
