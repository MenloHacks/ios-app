//
//  APIKeyStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIKeyStoreController : NSObject

+ (instancetype)sharedAPIKeyStoreController;

- (NSString *)getParseAppID;
- (NSString *)getParseClientID;
- (NSString *)getSmoochID;
@end
