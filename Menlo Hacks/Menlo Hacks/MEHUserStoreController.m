//
//  MEHUserStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/3/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHUserStoreController.h"

#import <Bolts/Bolts.h>
#import "RLMRealm+MenloHacks.h"

#import "JNKeychain.h"

#import "MEHHTTPSessionManager.h"
#import "MEHUser.h"



@interface MEHUserStoreController()


@end

static NSString *kMEHKeychainAuthTokenKey = @"com.menlohacks.authtoken.key";

@implementation MEHUserStoreController

+ (instancetype)sharedUserStoreController {
    static dispatch_once_t once;
    static MEHUserStoreController *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (BFTask *)loginWithUsername : (NSString *)username password : (NSString *)password {
    NSDictionary *parameters = @{@"username" : username,
                                 @"password" : password};
    
    return [[[MEHHTTPSessionManager sharedSessionManager]POST:@"user/login" parameters:parameters]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        NSDictionary *data = t.result[@"data"];
        
        NSString *token = data[@"token"];
        [JNKeychain saveValue:token forKey:kMEHKeychainAuthTokenKey];
        [[MEHHTTPSessionManager sharedSessionManager]setAuthorizationHeader];
        return [realm meh_TransactionWithBlock:^{
            RLMResults *allUsers = [MEHUser objectsWhere:@"username != %@", username];
            [realm deleteObjects:allUsers];
            MEHUser *user = [MEHUser userFromDictionary:data];
            [realm addOrUpdateObject:user];
        }];
    }];
}

- (NSString *)authToken {
    return [JNKeychain loadValueForKey:kMEHKeychainAuthTokenKey];
}

- (BOOL)isUserLoggedIn {
    return NO;
}


@end
