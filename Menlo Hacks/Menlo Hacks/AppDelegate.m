//
//  AppDelegate.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>
#import <Smooch/Smooch.h>

#import "APIKeyStoreController.h"
#import "ScheduleViewController.h"
#import "AnnouncementsViewController.h"
#import "MapViewController.h"
#import "MentorshipViewController.h"
#import "UIColor+ColorPalette.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark Application State Changes
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self configureAPIs];
  [self registerForPush:application];
  UITabBarController *tabBarController = [[UITabBarController alloc]init];
  tabBarController.tabBar.translucent = NO;
  UIViewController *vc1 = [[ScheduleViewController alloc]init];
  UIViewController *vc2 = [[AnnouncementsViewController alloc]init];
  UIViewController *vc3 = [[MapViewController alloc]init];
  UIViewController *vc4 = [[MentorshipViewController alloc]init];
  
  tabBarController.viewControllers =  @[vc1, vc2, vc3, vc4];
  
  UIImage *schedule = [UIImage imageNamed:@"schedule"];
  UIImage *announcements = [UIImage imageNamed:@"announcements"];
  UIImage *map = [UIImage imageNamed:@"map"];
  UIImage *mentor = [UIImage imageNamed:@"request_mentor"];
  
  UITabBarItem *item1 = [[UITabBarItem alloc]initWithTitle:@"Schedule" image:schedule selectedImage:schedule];
  UITabBarItem *item2 = [[UITabBarItem alloc]initWithTitle:@"Announcements" image:announcements selectedImage:announcements];
  UITabBarItem *item3 = [[UITabBarItem alloc]initWithTitle:@"Map" image:map selectedImage:map];
  UITabBarItem *item4 = [[UITabBarItem alloc]initWithTitle:@"Mentor" image:mentor selectedImage:mentor];
  
  vc1.tabBarItem = item1;
  vc2.tabBarItem = item2;
  vc3.tabBarItem = item3;
  vc4.tabBarItem = item4;
  
   [[UITabBar appearance] setTintColor:[UIColor menloBlue]];
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  UINavigationController* navController = [[UINavigationController alloc]initWithRootViewController:tabBarController];
  navController.navigationBar.topItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"menlo_hacks_logo_blue_nav"]];
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

#pragma mark Helper Methods
-(void)configureAPIs {
  NSString *parseAppID = [[APIKeyStoreController sharedAPIKeyStoreController]getParseAppID];
  NSString *parseClientID = [[APIKeyStoreController sharedAPIKeyStoreController]getParseClientID];
  
  [Parse setApplicationId:parseAppID
                clientKey:parseClientID];
  
  NSString *smoochID = [[APIKeyStoreController sharedAPIKeyStoreController]getSmoochID];
  [Smooch initWithSettings:
   [SKTSettings settingsWithAppToken:smoochID]];
  
}

-(void)registerForPush : (UIApplication *)application {
  UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
  UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
  [application registerUserNotificationSettings:settings];
  [application registerForRemoteNotifications];

}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  // Store the deviceToken in the current Installation and save it to Parse
  PFInstallation *currentInstallation = [PFInstallation currentInstallation];
  [currentInstallation setDeviceTokenFromData:deviceToken];
  [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  //Deal with any push notification stuff
  NSLog(@"apns recieved with user info = %@", userInfo);
}


@end
