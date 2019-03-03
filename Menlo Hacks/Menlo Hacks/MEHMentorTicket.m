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
    //We'll treat empty locations as empty strings.
    location = location ? location : @"";
    
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
        ticket.status =  MEHMentorTicketStatusClosed;
        
        ticket.primaryAction = MEHMentorActionReopen;
        ticket.secondaryAction = MEHMentorActionNone;
    } else if (ticket.claimed) {
        ticket.status = MEHMentorTicketStatusClaimed;
        ticket.primaryAction = MEHMentorActionReopen;
        ticket.secondaryAction = MEHMentorActionClose;
    } else if (ticket.expired) {
        ticket.status = MEHMentorTicketStatusExpired;
        
        ticket.primaryAction = MEHMentorActionReopen;
        ticket.secondaryAction = MEHMentorActionNone;
    } else {
        ticket.status = MEHMentorTicketStatusOpen;
        
        if(ticket.isMine) {
            ticket.primaryAction = MEHMentorActionClose;
            ticket.secondaryAction = MEHMentorActionNone;
        } else {
            ticket.primaryAction = MEHMentorActionClaim;
            ticket.secondaryAction = MEHMentorActionNone;
        }
    }
    
    
    
    return ticket;
}

#pragma mark custom setters/getters

- (MEHMentorTicketStatus)status {
    return (MEHMentorTicketStatus)self.rawStatus;
}

- (void)setStatus:(MEHMentorTicketStatus)status {
    self.rawStatus = status;
}

- (MEHMentorAction)primaryAction {
    return (MEHMentorAction)self.rawPrimaryAction;
}

- (void)setPrimaryAction:(MEHMentorAction)primaryAction {
    self.rawPrimaryAction = primaryAction;
}

- (MEHMentorAction)secondaryAction {
    return (MEHMentorAction)self.rawSecondaryAction;
}

- (void)setSecondaryAction:(MEHMentorAction)secondaryAction {
    self.rawSecondaryAction = secondaryAction;
}



+ (NSArray *)ignoredProperties {
    return @[@"status", @"primaryAction", @"secondaryAction"];
}

+ (NSString *)primaryKey {
    return @"serverID";
}

@end
