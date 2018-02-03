//
//  MEHAnnouncement.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 2/23/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHAnnouncement.h"

#import "NSDate+Utilities.h"

@implementation MEHAnnouncement

+ (instancetype)announcementFromDictionary: (NSDictionary *)dictionary {
    NSString *serverID = dictionary[@"id"];
    
    MEHAnnouncement *announcement = [MEHAnnouncement objectForPrimaryKey:serverID];
    if(!announcement) {
        announcement = [[MEHAnnouncement alloc]init];
        announcement.serverID = dictionary[@"id"];
    }
    
    if(![announcement.message isEqualToString:dictionary[@"message"]]) {
        announcement.message = dictionary[@"message"];
    }
    NSDate *time =[NSDate dateFromISOString:dictionary[@"time"]];
    if(![time isEqualToDate:announcement.time]) {
        announcement.time = time;
    }
    
    
    return announcement;
}

+ (NSString *)primaryKey {
    return @"serverID";
}

@end
