//
//  MEHUser.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/3/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHUser.h"

@implementation MEHUser

+ (instancetype)userFromDictionary : (NSDictionary *)dictionary {
    
    if(!dictionary) {
        return nil;
    }
    
    NSString *username = dictionary[@"username"];
    MEHUser *user = [MEHUser objectForPrimaryKey:username];
    if(!user) {
        user = [[MEHUser alloc]init];
        user.username = username;
    }
    user.name = dictionary[@"name"];
    
    return user;
}

+ (NSString *)primaryKey {
    return @"username";
}

@end
