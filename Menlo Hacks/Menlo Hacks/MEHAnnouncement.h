//
//  MEHAnnouncement.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 2/23/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <Realm/Realm.h>

@interface MEHAnnouncement : RLMObject

@property NSDate *time;
@property NSString *message;
@property NSString *serverID;


+ (instancetype)announcementFromDictionary: (NSDictionary *)dictionary;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<MEHAnnouncement *><MEHAnnouncement>
RLM_ARRAY_TYPE(MEHAnnouncement)
