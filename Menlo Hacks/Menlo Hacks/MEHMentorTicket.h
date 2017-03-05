//
//  MEHMentorTicket.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <Realm/Realm.h>

@interface MEHMentorTicket : RLMObject

+ (instancetype)ticketFromDictionary: (NSDictionary *)dictionary;

@property NSString *ticketDescription;
@property NSString *ticketLocation;
@property NSDate *timeCreated;
@property NSString *serverID;
@property BOOL claimed;
@property BOOL expired;
@property BOOL closed;

@property NSString *category;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<MEHMentorTicket *><MEHMentorTicket>
RLM_ARRAY_TYPE(MEHMentorTicket)
