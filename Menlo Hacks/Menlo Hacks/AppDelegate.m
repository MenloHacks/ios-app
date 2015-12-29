//
//  AppDelegate.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "AppDelegate.h"

#import <Parse/Parse.h>

#import "APIKeyStoreController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#pragma mark Application State Changes
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [self configureAPIs];
  
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
}

@end
