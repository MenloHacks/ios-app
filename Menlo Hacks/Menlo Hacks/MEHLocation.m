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
    location.locationName = dictionary[@"name"];
    location.mapURL = dictionary[@"map"];
    
    return location;
    
}

+ (NSString *)primaryKey {
    return @"serverID";
}

@end
