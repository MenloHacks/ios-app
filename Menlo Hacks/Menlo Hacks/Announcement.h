//
//  Announcement.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/1/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/Parse.h>

@interface Announcement : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) NSString *messageContents;
@property (retain) NSDate *fireTime;

@end