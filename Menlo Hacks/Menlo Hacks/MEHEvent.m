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
    
    event.shortDescription = dictionary[@"short_description"];
    event.longDescription = dictionary[@"long_description"];
    
    event.startTime = [NSDate dateFromISOString:dictionary[@"start_time"]];
    event.endTime = [NSDate dateFromISOString:dictionary[@"end_time"]];
    
    NSDictionary *locationDictionary = dictionary[@"location"];
    MEHLocation *location = [MEHLocation locationFromDictionary:locationDictionary];
    
    event.location = location;
    
    return event;
}

+ (NSString *)primaryKey {
    return @"serverID";
}

@end
