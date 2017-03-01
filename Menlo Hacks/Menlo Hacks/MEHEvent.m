//
//  Event.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "MEHEvent.h"

#import "NSDate+Utilities.h"


@implementation MEHEvent

+ (instancetype)eventFromDictionary: (NSDictionary *)dictionary {
    NSString *serverID = dictionary[@"id"];
    MEHEvent *event = [MEHEvent objectForPrimaryKey:serverID];
    if(!event) {
        event = [[MEHEvent alloc]init];
        event.serverID = dictionary[@"id"];
    }
    
    if(![event.shortDescription isEqualToString:dictionary[@"short_description"]]) {
        event.shortDescription = dictionary[@"short_description"];
    }
    if(![event.longDescription isEqualToString:dictionary[@"long_description"]]) {
        event.longDescription = dictionary[@"long_description"];
    }
    NSDate *startTime = [NSDate dateFromISOString:dictionary[@"start_time"]];
    
    if(![event.startTime isEqualToDate:startTime]) {
        event.startTime = startTime;
    }
    
    NSDate *endTime = [NSDate dateFromISOString:dictionary[@"end_time"]];
    if(![event.endTime isEqualToDate:endTime]) {
        event.endTime = endTime;
    }
    

    NSDictionary *locationDictionary = dictionary[@"location"];
    MEHLocation *location = [MEHLocation locationFromDictionary:locationDictionary];
    if(event.location && location && ![location.serverID isEqualToString:event.location.serverID]) {
        event.location = location;
    } else if (!event.location && location) {
        event.location = location;
    }
        
    
    

    
    return event;
}

+ (NSString *)primaryKey {
    return @"serverID";
}

@end
