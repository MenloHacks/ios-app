//
//  APIKeyStoreController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "APIKeyStoreController.h"

@interface APIKeyStoreController()

@property (nonatomic, strong) NSDictionary *apiKeyDictionary;

@end

@implementation APIKeyStoreController

+ (instancetype)sharedAPIKeyStoreController {
  static dispatch_once_t once;
  static APIKeyStoreController *_sharedInstance;
  dispatch_once(&once, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

- (instancetype)init {
  self = [super init];
  
  NSString *filePath = [[NSBundle mainBundle] pathForResource: @"API Keys" ofType: @"plist"];
  self.apiKeyDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
  
  return self;
}

- (NSString *)getParseAppID {
  return self.apiKeyDictionary[@"parse_application_id"];
}

- (NSString *)getParseClientID {
  return self.apiKeyDictionary[@"parse_client_id"];
}

- (NSString *)getSmoochID {
  return self.apiKeyDictionary[@"smooch"];
}



@end
