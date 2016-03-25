//
//  Event.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#import "EventLocation.h"

@interface Event : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) EventLocation *location;
@property (retain) NSDate *start_time;
@property (retain) NSDate *end_time;
@property (retain) NSString *long_description;
@property (retain) NSString *short_description;

@end