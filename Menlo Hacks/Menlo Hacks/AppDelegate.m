//
//  AppDelegate.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "AppDelegate.h"

#import "UIViewController+Extensions.h"

#import "MEHScheduleViewController.h"
#import "MEHAnnouncementsViewController.h"
#import "MEHMapViewController.h"
#import "MEHCheckInViewController.h"
#import "MEHDatabaseMigrationController.h"
#import "UIColor+ColorPalette.h"
#import "Menlo_Hacks-Swift.h"

@interface AppDelegate ()

@property (nonatomic, strong) UITabBarController *tabBarController;
@property (nonatomic, strong) MEHAnnouncementsViewController *announcementsVC;
@property (nonatomic, strong) MEHScheduleViewController *scheduleVC;

@end


@implementation AppDelegate

#pragma mark Application State Changes
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[MEHDatabaseMigrationController sharedMigrator]handleMigrations];
  _tabBarController = [[UITabBarController alloc]init];
  _tabBarController.tabBar.translucent = NO;
  MEHScheduleViewController *vc1 = [[MEHScheduleViewController alloc]init];
  MEHAnnouncementsViewController *vc2 = [[MEHAnnouncementsViewController alloc]init];
  MEHCheckInViewController *vc3 = [[MEHCheckInViewController alloc]init];
  MEHMapViewController *vc4 = [[MEHMapViewController alloc]init];
  MEHMentorshipPageViewController *vc5 = [[MEHMentorshipPageViewController alloc]init];
    
    
  
  _announcementsVC = vc2;
  _scheduleVC = vc1;
  
  _tabBarController.viewControllers =  @[vc1, vc2, vc3, vc4, vc5];
    
  [[NotificationHandler shared]initialize];
    
  
  UIImage *schedule = [UIImage imageNamed:@"schedule"];
  UIImage *announcements = [UIImage imageNamed:@"announcements"];
  UIImage *map = [UIImage imageNamed:@"map"];
  UIImage *mentor = [UIImage imageNamed:@"request_mentor"];
  UIImage *checkIn = [UIImage imageNamed:@"profile"];
  
  UITabBarItem *item1 = [[UITabBarItem alloc]initWithTitle:@"Schedule" image:schedule selectedImage:schedule];
  UITabBarItem *item2 = [[UITabBarItem alloc]initWithTitle:@"Announcements" image:announcements selectedImage:announcements];
  UITabBarItem *item3 = [[UITabBarItem alloc]initWithTitle:@"Check-In" image:checkIn selectedImage:checkIn];
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


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    [[NotificationHandler shared]registerWithDeviceToken:deviceToken];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

}


@end
