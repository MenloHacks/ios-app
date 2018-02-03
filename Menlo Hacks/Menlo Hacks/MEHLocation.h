//
//  EventLocation.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/24/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import <Realm/Realm.h>

@interface MEHLocation : RLMObject


+ (instancetype)locationFromDictionary : (NSDictionary *)dictionary;

@property NSString *locationName;
@property NSString *mapURL;
@property NSString *serverID;
@property BOOL isPrimary;
@property NSInteger rank;

@end

RLM_ARRAY_TYPE(MEHLocation)
