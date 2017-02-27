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
    
    announcement.message = dictionary[@"message"];
    announcement.time = [NSDate dateFromISOString:dictionary[@"time"]];
    
    return announcement;
}

@end
