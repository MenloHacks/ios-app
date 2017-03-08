//
//  MEHMentorshipStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MEHMentorTicket.h"

@class BFTask;


@interface MEHMentorshipStoreController : NSObject

+ (instancetype)sharedMentorshipStoreController;

- (BFTask *)fetchQueue;
- (BFTask *)fetchClaimedQueue;
- (BFTask *)fetchUserQueue;

- (BFTask *)createTicket : (NSString *)description location : (NSString *)location contact : (NSString *)contact;

- (BFTask *)performAction: (MEHMentorAction)action onTicketWithIdentifier : (NSString *)serverID;
+ (NSString *)verbForAction : (MEHMentorAction)action;

- (BFTask *)didReceiveNotification : (NSArray *)notification;


@end
