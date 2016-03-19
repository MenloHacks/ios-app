//
//  MapStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/2/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Map;

@interface MapStoreController : NSObject

+ (instancetype)sharedMapStoreController;
- (void)getMaps : (void (^)(NSArray<Map *> * results))completion;


@end
