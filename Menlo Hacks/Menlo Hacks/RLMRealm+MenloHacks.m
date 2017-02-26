//
//  RLMRealm+MenloHacks.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 2/24/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "RLMRealm+MenloHacks.h"

#import <Bolts/Bolts.h>

@implementation RLMRealm (MenloHacks)

- (BFTask *)meh_TransactionWithBlock: (void (^)(void))block {
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    NSError *error;
    BOOL result = [self transactionWithBlock:block error:&error];
    [completionSource setResult:@(result)];
    if(error) {
        [completionSource setError:error];
    }
    return completionSource.task;
}

@end
