//
//  MEHNotificationHandler.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 2/27/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHNotificationHandler.h"

#import <Pusher/Pusher.h>

#import "MEHAPIKeys.h"
#import "MEHAnnouncementsStoreController.h"
#import "MEHScheduleStoreController.h"
#import "MEHMentorshipStoreController.h"

@import UserNotifications;
@import UIKit;

@interface MEHNotificationHandler()<PTPusherDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) PTPusher *pusher;

@end

static NSString * const kMEHNotificationTopic = @"com.vivereiii.all_devices";

static NSString *kMEHAnnouncementUpdate = @"com.vivereiii.update";
static NSString *kMEHMentorUpdate = @"com.vivereiii.update";
static NSString *kMEHEventUpdate = @"com.vivereiii.update";

static NSString *kMEHChannelAction = @"save";
static NSString *kMEHMentorshipExpireAction = @"expire";

@implementation MEHNotificationHandler

+ (instancetype)sharedNotificationHandler {
    static dispatch_once_t onceToken;
    static MEHNotificationHandler *_sharedNotificationHandler;
    dispatch_once(&onceToken, ^{
        _sharedNotificationHandler = [[self alloc]init];
    });
    return _sharedNotificationHandler;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        self.pusher = [PTPusher pusherWithKey:kMEHNotificationAPIKey delegate:self encrypted:YES];
        [self.pusher connect];
        [self configureAPNS];
        [self bindToChannels];
    }
    return self;
}

- (void)configureAPNS {
    UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
    }];
        
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
}


- (void)bindToChannels {
    
    PTPusherChannel *announcementChannel = [self.pusher subscribeToChannelNamed:kMEHAnnouncementUpdate];
    [announcementChannel bindToEventNamed:kMEHChannelAction handleWithBlock:^(PTPusherEvent *channelEvent) {
        [[MEHAnnouncementsStoreController sharedAnnouncementsStoreController]didReceiveNotification:channelEvent.data];
    }];
    
    PTPusherChannel *eventChannel = [self.pusher subscribeToChannelNamed:kMEHEventUpdate];
    [eventChannel bindToEventNamed:kMEHChannelAction handleWithBlock:^(PTPusherEvent *channelEvent) {
        [[MEHScheduleStoreController sharedScheduleStoreController]didReceiveNotification:channelEvent.data];
    }];
    
    PTPusherChannel *mentorChannel = [self.pusher subscribeToChannelNamed:kMEHMentorUpdate];
    [mentorChannel bindToEventNamed:kMEHChannelAction handleWithBlock:^(PTPusherEvent *channelEvent) {
        [[MEHMentorshipStoreController sharedMentorshipStoreController]didReceiveNotification:@[channelEvent.data]];
    }];
    
    [mentorChannel bindToEventNamed:kMEHMentorshipExpireAction handleWithBlock:^(PTPusherEvent *channelEvent) {
        [[MEHMentorshipStoreController sharedMentorshipStoreController]didReceiveNotification:channelEvent.data];
    }];
}

- (void)handleNotificationPayload : (NSDictionary *)userInfo {
 
}


- (void)registerDeviceToken : (NSData *)token {
    [self.pusher.nativePusher registerWithDeviceToken:token];
    //Register all devices into the default notification topic.
    [self.pusher.nativePusher subscribe:kMEHNotificationTopic];
}


@end
