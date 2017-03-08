//
//  MEHMentorTicket.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHMentorTicket.h"

#import "NSDate+Utilities.h"

NSString * kMEHQueueCategory = @"open";
NSString * kMEHExpiredCategory = @"expired";
NSString * kMEHInProgressCategory = @"in_progress";
NSString * kMEHClosedCategory = @"closed";

@implementation MEHMentorTicket

+ (instancetype)ticketFromDictionary: (NSDictionary *)dictionary {
    if(!dictionary) {
        return nil;
    }
    NSString *serverID = dictionary[@"id"];
    
    MEHMentorTicket *ticket = [MEHMentorTicket objectForPrimaryKey:serverID];
    if(!ticket) {
        ticket = [[MEHMentorTicket alloc]init];
        ticket.serverID = serverID;
    }
    
    NSString *description = dictionary[@"description"];
    
    if(![ticket.ticketDescription isEqualToString:description]) {
        ticket.ticketDescription = description;
    }
    
    
    NSString *location = dictionary[@"location"];
    
    if (![ticket.ticketLocation isEqualToString:location]) {
        ticket.ticketLocation = location;
    }
    
    NSString *contact = dictionary[@"contact"];
    
    if (![ticket.contact isEqualToString:contact]) {
        ticket.contact = contact;
    }
    
    NSDate *timeCreated =[NSDate dateFromISOString:dictionary[@"time_created"]];
    
    if (![ticket.timeCreated isEqualToDate:timeCreated]) {
        ticket.timeCreated = timeCreated;
    }
    
    BOOL claimed = [dictionary[@"claimed"]boolValue];
    
    if(ticket.claimed != claimed) {
        ticket.claimed = claimed;
    }
    
    BOOL expired = [dictionary[@"expired"]boolValue];
    
    if(ticket.expired != expired) {
        ticket.expired = expired;
    }
    
    id timeComplete = dictionary[@"time_complete"];
    
    if (timeComplete == [NSNull null]) {
        if(ticket.closed == YES) {
            ticket.closed = NO;
        }
    } else {
        if(ticket.closed == NO) {
            ticket.closed = YES;
        }
    }
    
    BOOL isMine = [dictionary[@"is_mine"]boolValue];
    if (ticket.isMine != isMine) {
        ticket.isMine = isMine;
    }
    
    BOOL claimedByMe = [dictionary[@"claimed_by_me"]boolValue];
    if (ticket.claimedByMe != claimedByMe) {
        ticket.claimedByMe = claimedByMe;
    }
    
    if(ticket.closed) {
        ticket.category = kMEHClosedCategory;
    } else if (ticket.claimed) {
        ticket.category = kMEHInProgressCategory;
    } else if (ticket.expired) {
        ticket.category = kMEHExpiredCategory;
    } else {
        ticket.category = kMEHQueueCategory;
    }
    
    
    return ticket;
}

+ (NSString *)categoryForAction : (MEHMentorAction)action {
    
    static dispatch_once_t once;
    static NSDictionary *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = @{
                            @(MEHMentorActionClaim) : kMEHInProgressCategory,
                            @(MEHMentorActionClose) : kMEHClosedCategory,
                            @(MEHMentorActionReopen) : kMEHQueueCategory
                            };
    });
    
    return _sharedInstance[@(action)];
    
}


+ (NSString *)primaryKey {
    return @"serverID";
}

@end
