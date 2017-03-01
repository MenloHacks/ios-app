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

@import UserNotifications;
@import UIKit;

@interface MEHNotificationHandler()<PTPusherDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic, strong) PTPusher *pusher;

@end

static NSString * const kMEHNotificationTopic = @"com.vivere.all_devices";

static NSString *kMEHAnnouncementUpdate = @"com.vivere.announcement.update";
static NSString *kMEHMentorUpdate = @"com.vivere.mentor.update";
static NSString *kMEHEventUpdate = @"com.vivere.event.update";

static NSString *kMEHChannelAction = @"save";


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
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    } else {
        // iOS 10 or later
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        UNAuthorizationOptions authOptions =
        UNAuthorizationOptionAlert
        | UNAuthorizationOptionSound
        | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
        }];
        
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
#endif
    }
    
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
