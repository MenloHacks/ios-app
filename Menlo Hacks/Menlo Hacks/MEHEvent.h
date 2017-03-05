//
//  Event.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <Realm/Realm.h>

#import "MEHLocation.h"

@interface MEHEvent: RLMObject


@property MEHLocation *location;

@property NSDate *startTime;
@property NSDate *endTime;

@property NSString *longDescription;
@property NSString *shortDescription;

@property NSString *serverID;

+ (instancetype)eventFromDictionary: (NSDictionary *)dictionary;


@end

RLM_ARRAY_TYPE(MEHEvent)
