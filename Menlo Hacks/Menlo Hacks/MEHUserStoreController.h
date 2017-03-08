//
//  MEHUserStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/3/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask;

@interface MEHUserStoreController : NSObject

+ (instancetype)sharedUserStoreController;
- (BFTask *)loginWithUsername : (NSString *)username password : (NSString *)password;

- (BOOL)isUserLoggedIn;
- (NSString *)authToken;
- (NSString *)loggedInUserID;
- (BFTask *)getPass;
- (void)logout;

@end
