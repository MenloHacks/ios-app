//
//  AppDelegate.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "AppDelegate.h"


#import "MEHScheduleViewController.h"
#import "MEHAnnouncementsViewController.h"
#import "LargeTimeViewController.h"
#import "MEHMapViewController.h"
#import "MentorshipViewController.h"
#import "MEHNotificationHandler.h"
#import "UIColor+ColorPalette.h"

@interface AppDelegate ()

@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) MEHAnnouncementsViewController *announcementsVC;
@property (nonatomic, strong) MEHScheduleViewController *scheduleVC;

@end

static NSString *kMHNotificationTypeAnnouncement = @"announcement";
static NSString *kMHNotificationTypeEvent = @"event";

@implementation AppDelegate

#pragma mark Application State Changes
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self configureAPIs];
  [self registerForPush:application];
  _tabBarController = [[UITabBarController alloc]init];
  _tabBarController.tabBar.translucent = NO;
  MEHScheduleViewController *vc1 = [[MEHScheduleViewController alloc]init];
  MEHAnnouncementsViewController *vc2 = [[MEHAnnouncementsViewController alloc]init];
  LargeTimeViewController *vc3 = [[LargeTimeViewController alloc]init];
  MEHMapViewController *vc4 = [[MEHMapViewController alloc]init];
  MentorshipViewController *vc5 = [[MentorshipViewController alloc]init];
  
  _announcementsVC = vc2;
  _scheduleVC = vc1;
  
  _tabBarController.viewControllers =  @[vc1, vc2, vc3, vc4, vc5];
    
  [MEHNotificationHandler sharedNotificationHandler];
    
  
  UIImage *schedule = [UIImage imageNamed:@"schedule"];
  UIImage *announcements = [UIImage imageNamed:@"announcements"];
  UIImage *map = [UIImage imageNamed:@"map"];
  UIImage *mentor = [UIImage imageNamed:@"request_mentor"];
  UIImage *countdown = [UIImage imageNamed:@"countdown"];
  
  UITabBarItem *item1 = [[UITabBarItem alloc]initWithTitle:@"Schedule" image:schedule selectedImage:schedule];
  UITabBarItem *item2 = [[UITabBarItem alloc]initWithTitle:@"Announcements" image:announcements selectedImage:announcements];
  UITabBarItem *item3 = [[UITabBarItem alloc]initWithTitle:@"Countdown" image:countdown selectedImage:countdown];
  UITabBarItem *item4 = [[UITabBarItem alloc]initWithTitle:@"Map" image:map selectedImage:map];
  UITabBarItem *item5 = [[UITabBarItem alloc]initWithTitle:@"Mentor" image:mentor selectedImage:mentor];
  
  vc1.tabBarItem = item1;
  vc2.tabBarItem = item2;
  vc3.tabBarItem = item3;
  vc4.tabBarItem = item4;
  vc5.tabBarItem = item5;
  
   [[UITabBar appearance] setTintColor:[UIColor menloHacksPurple]];
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  UINavigationController* navController = [[UINavigationController alloc]initWithRootViewController:_tabBarController];
  navController.navigationBar.tintColor = [UIColor menloHacksPurple];
  navController.navigationBar.topItem.titleView = [[UIImageView alloc]initWithImage:
                                                   [UIImage imageNamed:@"menlohacks_nav"]];
  navController.navigationBar.translucent = NO;
  _window.rootViewController = navController;
  [_window makeKeyAndVisible];
  
  return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

  
}

- (void)applicationWillTerminate:(UIApplication *)application {

  
}

- (void)switchToCountdown {
  [self.tabBarController setSelectedIndex:2];
}

#pragma mark Helper Methods
-(void)configureAPIs {
  

  
}

-(void)registerForPush : (UIApplication *)application {
  UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
  UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
  [application registerUserNotificationSettings:settings];
  [application registerForRemoteNotifications];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[MEHNotificationHandler sharedNotificationHandler]registerDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  //Deal with any push notification stuff
//  NSString *type = userInfo[@"type"];
//  if([type isEqualToString:kMHNotificationTypeEvent]) {
//    [_scheduleVC refresh];
//  }
//  else if ([type isEqualToString:kMHNotificationTypeAnnouncement]){
//    [_announcementsVC forceRefresh];
//  }
}


@end
