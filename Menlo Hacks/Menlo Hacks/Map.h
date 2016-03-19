//
//  Map.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/2/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Map : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property (retain) PFFile *image;
@property (retain) NSString *caption;

@end