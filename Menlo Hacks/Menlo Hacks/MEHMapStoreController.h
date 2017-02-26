//
//  MapStoreController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/2/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BFTask, RLMResults;

@interface MEHMapStoreController : NSObject

+ (instancetype)sharedMapStoreController;

- (BFTask *)fetchMaps;
- (RLMResults *)maps;



@end
