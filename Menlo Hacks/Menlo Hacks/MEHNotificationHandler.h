//
//  MEHNotificationHandler.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 2/27/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEHNotificationHandler : NSObject

+ (instancetype)sharedNotificationHandler;
- (void)registerDeviceToken : (NSData *)token;

@end
