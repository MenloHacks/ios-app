//
//  EventLocation.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/24/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "MEHLocation.h"

@implementation MEHLocation

+ (instancetype)locationFromDictionary:(NSDictionary *)dictionary {
    NSString *serverID = dictionary[@"id"];
    MEHLocation *location = [MEHLocation objectForPrimaryKey:serverID];
    if(!location) {
        location = [[MEHLocation alloc]init];
        location.serverID = serverID;
    }
    if(![location.locationName isEqualToString:dictionary[@"name"]]) {
        location.locationName = dictionary[@"name"];
    }
    
    if(![location.mapURL isEqualToString:dictionary[@"map"]]) {
       location.mapURL = dictionary[@"map"];
    }
    
    if(location.isPrimary != [dictionary[@"is_primary"]boolValue]) {
        
    }location.isPrimary = [dictionary[@"is_primary"]boolValue];
    
    
    if (dictionary[@"rank"] && location.rank != [dictionary[@"rank"]integerValue]) {
        location.rank = [dictionary[@"rank"]integerValue];
    }
    
    return location;
    
}

+ (NSString *)primaryKey {
    return @"serverID";
}

@end
