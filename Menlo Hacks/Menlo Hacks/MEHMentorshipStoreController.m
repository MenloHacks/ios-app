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
                __block NSMutableArray *ticketIDs = [NSMutableArray array];
                RLMRealm *realm = [RLMRealm defaultRealm];
                return [[realm meh_TransactionWithBlock:^{
                    for (NSDictionary *ticketDictionary in tickets) {
                        MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:ticketDictionary];
                        ticket.category = kMEHQueueCategory;
                        [ticketIDs addObject:ticket.serverID];
                        [realm addOrUpdateObject:ticket];
                    }
                    
                }]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                    RLMResults *objectsToDelete = [MEHMentorTicket objectsWhere:@"NOT (serverID IN %@) AND category = %@", ticketIDs, kMEHQueueCategory];
                    return [realm meh_TransactionWithBlock:^{
                        [realm deleteObjects:objectsToDelete];
                    }];
                }];
                
            }];
}

- (BFTask *)fetchUserQueue {
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"mentorship/user/queue" parameters:nil]
            continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                __block NSDictionary *data = t.result[@"data"];
                NSDictionary *tickets = data[@"tickets"];
                __block NSMutableArray *ticketIDs = [NSMutableArray array];
                RLMRealm *realm = [RLMRealm defaultRealm];
                return [[realm meh_TransactionWithBlock:^{
                    for (NSString *key in tickets) {
                        NSArray *ticketsList = tickets[key];
                        for (NSDictionary *ticketDictionary in ticketsList) {
                            MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:ticketDictionary];
                            ticket.category = key;
                            [ticketIDs addObject:ticket.serverID];
                            [realm addOrUpdateObject:ticket];
                        }
                    }

                    
                }]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                    NSArray *categories = data[@"categories"];
                    RLMResults *objectsToDelete = [MEHMentorTicket objectsWhere:@"NOT (serverID IN %@) AND (category IN %@)", ticketIDs, categories];
                    return [[realm meh_TransactionWithBlock:^{
                        [realm deleteObjects:objectsToDelete];
                    }]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                        return [BFTask taskWithResult:data[@"categories"]];
                    }];
                }];
                
            }];
}

- (BFTask *)fetchClaimedQueue {
    return [[[MEHHTTPSessionManager sharedSessionManager]GET:@"mentorship/user/claimed" parameters:nil]
            continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                NSArray *tickets = t.result[@"data"];
                __block NSMutableArray *ticketIDs = [NSMutableArray array];
                RLMRealm *realm = [RLMRealm defaultRealm];
                return [[realm meh_TransactionWithBlock:^{
                    for (NSDictionary *ticketDictionary in tickets) {
                        MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:ticketDictionary];
                        [ticketIDs addObject:ticket.serverID];
                        [realm addOrUpdateObject:ticket];
                    }
                    
                }]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                    RLMResults *objectsToDelete = [MEHMentorTicket objectsWhere:@"NOT (serverID IN %@) AND category = %@", ticketIDs, kMEHInProgressCategory];
                    return [realm meh_TransactionWithBlock:^{
                        [realm deleteObjects:objectsToDelete];
                    }];
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
            MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:t.result[@"data"]];
            ticket.category = kMEHQueueCategory;
            [realm addOrUpdateObject:ticket];
        }];

        
    }];
    
}

- (BFTask *)performAction: (MEHMentorAction)action onTicketWithIdentifier : (NSString *)serverID {
    NSString *verb = [[self class]verbForAction:action];
    if(!verb) {
        return [BFTask taskWithError:[NSError errorWithDomain:@"com.menlohacks.mentorship" code:0 userInfo:@{@"message" : @"Invalid action"}]];
    }
    NSString *path = [NSString stringWithFormat:@"mentorship/%@", verb];
    NSDictionary *parameters = @{@"id" : serverID};
    
    return [[[MEHHTTPSessionManager sharedSessionManager]POST:path parameters:parameters]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        RLMRealm *realm = [RLMRealm defaultRealm];
        return [realm meh_TransactionWithBlock:^{
            MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:t.result[@"data"]];
            ticket.category = [MEHMentorTicket categoryForAction:action];
            [realm addOrUpdateObject:ticket];
        }];
    }];
}


- (BFTask *)didReceiveNotification : (NSArray *)notification {
    RLMRealm *realm = [RLMRealm defaultRealm];
    return [realm meh_TransactionWithBlock:^{
        for (NSDictionary *ticketDictionary in notification) {
            MEHMentorTicket *ticket = [MEHMentorTicket ticketFromDictionary:ticketDictionary];
            [realm addOrUpdateObject:ticket];
        }
    }];

}
+ (NSString *)verbForAction : (MEHMentorAction)action {

    static dispatch_once_t once;
    static NSDictionary *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = @{
                            @(MEHMentorActionClaim) : @"claim",
                            @(MEHMentorActionClose) : @"close",
                            @(MEHMentorActionReopen) : @"reopen"
                            };
    });
    
    return _sharedInstance[@(action)];
    
}




@end
