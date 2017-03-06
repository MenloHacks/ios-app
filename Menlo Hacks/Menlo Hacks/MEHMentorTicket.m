//
//  MEHMentorTicket.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHMentorTicket.h"

#import "NSDate+Utilities.h"

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
    return ticket;
}



+ (NSString *)primaryKey {
    return @"serverID";
}

@end
