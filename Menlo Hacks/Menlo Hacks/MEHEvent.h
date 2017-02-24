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


@property (retain) MEHLocation *location;

@property (retain) NSDate *startTime;
@property (retain) NSDate *endTime;

@property (retain) NSString *longDescription;
@property (retain) NSString *shortDescription;

@end
