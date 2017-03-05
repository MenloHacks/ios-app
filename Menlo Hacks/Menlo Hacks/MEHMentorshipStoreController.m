//
//  MEHMentorshipStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHMentorshipStoreController.h"

#import <Bolts/Bolts.h>
#import "RLMRealm+MenloHacks.h"

#import "MEHHTTPSessionManager.h"
#import "MEHMentorTicket.h"

NSString * kMEHQueueCategory = @"queue";
NSString * kMEHClaimedCategory = @"claimed";


@implementation MEHMentorshipStoreController


+ (instancetype)sharedMentorshipStoreController {
    static dispatch_once_t once;
    static MEHMentorshipStoreController *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (BFTask *)fetchQueue {
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"mentorship/queue" parameters:nil]
            continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                NSArray *tickets = t.result[@"data"];
                RLMRealm *realm = [RLMRealm defaultRealm];
                return [realm meh_TransactionWithBlock:^{
                    for (NSDictionary *ticketDictionary in tickets) {
                        MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:ticketDictionary];
                        ticket.category = kMEHQueueCategory;
                        [realm addObject:ticket];
                    }
                    
                }];
                
            }];
}

//- (BFTask *)fetchUserQueue {
//    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"mentorship/user/queue" parameters:nil]
//            continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
//                NSArray *tickets = t.result[@"data"];
//                RLMRealm *realm = [RLMRealm defaultRealm];
//                return [realm meh_TransactionWithBlock:^{
//                    for (NSDictionary *ticketDictionary in tickets) {
//                        MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:ticketDictionary];
//                        [realm addObject:ticket];
//                    }
//                    
//                }];
//                
//            }];
//}

- (BFTask *)fetchClaimedQueue {
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"mentorship/user/claimed" parameters:nil]
            continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                NSArray *tickets = t.result[@"data"];
                RLMRealm *realm = [RLMRealm defaultRealm];
                return [realm meh_TransactionWithBlock:^{
                    for (NSDictionary *ticketDictionary in tickets) {
                        MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:ticketDictionary];
                        ticket.category = kMEHClaimedCategory;
                        [realm addObject:ticket];
                    }
                    
                }];
                
            }];
}

@end
