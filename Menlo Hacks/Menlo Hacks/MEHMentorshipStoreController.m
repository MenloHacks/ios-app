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

NSString * kMEHQueueCategory = @"open";
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
                        [realm addOrUpdateObject:ticket];
                    }
                    
                }];
                
            }];
}

- (BFTask *)fetchUserQueue {
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"mentorship/user/queue" parameters:nil]
            continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                __block NSDictionary *data = t.result[@"data"];
                NSDictionary *tickets = data[@"tickets"];
                RLMRealm *realm = [RLMRealm defaultRealm];
                return [[realm meh_TransactionWithBlock:^{
                    for (NSString *key in tickets) {
                        NSArray *ticketsList = tickets[key];
                        for (NSDictionary *ticketDictionary in ticketsList) {
                            MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:ticketDictionary];
                            ticket.category = key;
                            [realm addOrUpdateObject:ticket];
                        }
                    }

                    
                }]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                    return data[@"categories"];
                }];
                
            }];
}

- (BFTask *)fetchClaimedQueue {
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"mentorship/user/claimed" parameters:nil]
            continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                NSArray *tickets = t.result[@"data"];
                RLMRealm *realm = [RLMRealm defaultRealm];
                return [realm meh_TransactionWithBlock:^{
                    for (NSDictionary *ticketDictionary in tickets) {
                        MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:ticketDictionary];
                        ticket.category = kMEHClaimedCategory;
                        [realm addOrUpdateObject:ticket];
                    }
                    
                }];
                
            }];
}

- (BFTask *)createTicket : (NSString *)description location : (NSString *)location contact : (NSString *)contact {
    NSDictionary *parameters = @{@"description" : description,
                                 @"location" : location,
                                 @"contact" : contact};
    
    return [[[MEHHTTPSessionManager sharedSessionManager]POST:@"mentorship/create" parameters:parameters]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        return [realm meh_TransactionWithBlock:^{
            MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:t.result];
            ticket.category = kMEHQueueCategory;
            [realm addOrUpdateObject:ticket];
        }];

        
    }];
    
    
}

@end
