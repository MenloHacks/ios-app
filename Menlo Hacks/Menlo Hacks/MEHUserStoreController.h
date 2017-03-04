//
//  MEHUserStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/3/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEHUserStoreController : NSObject

+ (instancetype)sharedUserStoreController;

- (BOOL)isUserLoggedIn;

@end
