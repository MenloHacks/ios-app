//
//  MEHUserStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/3/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHUserStoreController.h"

@interface MEHUserStoreController()


@end

@implementation MEHUserStoreController

+ (instancetype)sharedUserStoreController {
    static dispatch_once_t once;
    static MEHUserStoreController *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}


- (BOOL)isUserLoggedIn {
    return NO;
}


@end
