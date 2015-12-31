//
//  Event.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Event : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *eventDescription;
@property (retain) NSString *location;
@property (retain) NSDate *time;

@end