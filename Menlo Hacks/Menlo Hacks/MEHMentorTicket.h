//
//  MEHMentorTicket.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <Realm/Realm.h>

extern NSString * kMEHQueueCategory;
extern NSString * kMEHExpiredCategory;
extern NSString * kMEHInProgressCategory;
extern NSString * kMEHClosedCategory;


typedef enum : NSUInteger {
    MEHMentorActionClaim=0,
    MEHMentorActionReopen=1,
    MEHMentorActionClose=2,
} MEHMentorAction;

@interface MEHMentorTicket : RLMObject

+ (instancetype)ticketFromDictionary: (NSDictionary *)dictionary;

@property NSString *ticketDescription;
@property NSString *ticketLocation;
@property NSString *contact;
@property NSDate *timeCreated;
@property NSString *serverID;
@property BOOL claimed;
@property BOOL expired;
@property BOOL closed;
@property BOOL isMine;
@property BOOL claimedByMe;

@property NSString *category;

+ (NSString *)categoryForAction : (MEHMentorAction)action;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<MEHMentorTicket *><MEHMentorTicket>
RLM_ARRAY_TYPE(MEHMentorTicket)
