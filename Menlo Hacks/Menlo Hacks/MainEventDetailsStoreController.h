//
//  MainEventDetailsStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MainEventDetailsStoreController : NSObject

+ (instancetype)sharedMainEventDetailsStoreController;
- (void)getEventStartTimeWithCompletion: (void (^)(NSDate * date))completion;
- (void)getEventEndTimeWithCompletion: (void (^)(NSDate * date))completion;
@end
