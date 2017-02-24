//
//  EventLocation.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/24/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import <Realm/Realm.h>

@interface MEHLocation : RLMObject

+ (NSString *)parseClassName;

@property (retain) NSString *locationName;
@property (retain) NSString *mapURL;

@end
