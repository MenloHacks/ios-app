//
//  MEHDatabaseMigrationController.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/1/18.
//  Copyright © 2018 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MEHDatabaseMigrationController : NSObject

+ (instancetype)sharedMigrator;
- (void)handleMigrations;


@end
