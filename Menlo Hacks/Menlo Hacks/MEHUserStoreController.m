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
static NSString *kMEHCurrentUsernameKey = @"com.menlohacks.username.key";

@implementation MEHUserStoreController

+ (instancetype)sharedUserStoreController {
    static dispatch_once_t once;
    static MEHUserStoreController *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        NSString *username = [JNKeychain loadValueForKey:kMEHKeychainAuthTokenKey];
        if(username) {
            if (![MEHUser objectForPrimaryKey:username]) {
                [JNKeychain saveValue:nil forKey:kMEHKeychainAuthTokenKey];
                [JNKeychain saveValue:nil forKey:kMEHCurrentUsernameKey];
            }
        }
        
    }
    
    return self;
}

- (BFTask *)loginWithUsername : (NSString *)username password : (NSString *)password {
    NSDictionary *parameters = @{@"username" : username,
                                 @"password" : password};
    
    return [[[MEHHTTPSessionManager sharedSessionManager]POST:@"user/login" parameters:parameters]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        NSDictionary *data = t.result[@"data"];
        
        NSString *token = data[@"token"];
        [JNKeychain saveValue:token forKey:kMEHKeychainAuthTokenKey];
        [JNKeychain saveValue:username forKey:kMEHCurrentUsernameKey];
        [[MEHHTTPSessionManager sharedSessionManager]setAuthorizationHeader];
        return [realm meh_TransactionWithBlock:^{
            MEHUser *user = [MEHUser userFromDictionary:data];
            [realm addOrUpdateObject:user];
        }];
    }];
}

- (void)logout {
    [JNKeychain saveValue:nil forKey:kMEHKeychainAuthTokenKey];
    [JNKeychain saveValue:nil forKey:kMEHCurrentUsernameKey];
}

- (NSString *)loggedInUserID {
    return [JNKeychain loadValueForKey:kMEHCurrentUsernameKey];
}

- (NSString *)authToken {
    return [JNKeychain loadValueForKey:kMEHKeychainAuthTokenKey];
}

- (BOOL)isUserLoggedIn {
    return [JNKeychain loadValueForKey:kMEHKeychainAuthTokenKey];
}

- (BFTask *)getPass {
    return [[MEHHTTPSessionManager sharedSessionManager]downloadResource:@"user/ticket"];
}


@end
