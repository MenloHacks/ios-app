//
//  EventLocation.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/24/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import <Parse/Parse.h>

@interface EventLocation : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *location_name;
@property (retain) PFFile *map_image;

@end