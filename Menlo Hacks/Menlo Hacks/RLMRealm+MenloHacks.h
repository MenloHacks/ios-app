//
//  RLMRealm+MenloHacks.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 2/24/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <Realm/Realm.h>

@class BFTask;

@interface RLMRealm (MenloHacks)

- (BFTask *)meh_TransactionWithBlock: (void (^)(void))block;

@end
