//
//  MEHDatabaseMigrationController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/1/18.
//  Copyright © 2018 MenloHacks. All rights reserved.
//

#import "MEHDatabaseMigrationController.h"

#import <Realm/Realm.h>

@implementation MEHDatabaseMigrationController

static NSString *kMEHCachedVersionNumber = @"com.menlohacks.versionNumber";


+ (instancetype)sharedMigrator {
    static dispatch_once_t onceToken;
    static MEHDatabaseMigrationController *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc]init];
    });
    return _sharedInstance;
}

- (void)handleMigrations {
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *cachedVersion = [[NSUserDefaults standardUserDefaults]objectForKey:kMEHCachedVersionNumber];
    if(!cachedVersion || [cachedVersion compare: version] == NSOrderedAscending) {
        [[NSFileManager defaultManager] removeItemAtURL:[RLMRealmConfiguration defaultConfiguration].fileURL error:nil];
    }
    [[NSUserDefaults standardUserDefaults]setObject:version forKey:kMEHCachedVersionNumber];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    // Set the new schema version. This must be greater than the previously used
    // version (if you've never set a schema version before, the version is 0).
    config.schemaVersion = 2;
    
    // Set the block which will be called automatically when opening a Realm with a
    // schema version lower than the one set above
    config.migrationBlock = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
        // We haven’t migrated anything yet, so oldSchemaVersion == 0
        if (oldSchemaVersion < 2) {

        }
        
    };
    
    // Tell Realm to use this new configuration object for the default Realm
    [RLMRealmConfiguration setDefaultConfiguration:config];
    
    // Now that we've told Realm how to handle the schema change, opening the file
    // will automatically perform the migration
    [RLMRealm defaultRealm];
}


@end
