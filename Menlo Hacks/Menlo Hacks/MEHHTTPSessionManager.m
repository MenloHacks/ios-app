//
//  MEHHTTPSessionManager.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 2/23/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHHTTPSessionManager.h"

#import <Bolts/Bolts.h>
#import "JNKeychain.h"
#import "FCAlertView.h"

#import "MEHUserStoreController.h"


static NSString * kMEHAuthorizationHeaderField = @"X-MenloHacks-Authorization";

@implementation MEHHTTPSessionManager

+ (instancetype)sharedSessionManager {
    static dispatch_once_t once;
    static MEHHTTPSessionManager *_sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.menlohacks.com/"]];
    });
    
    return _sharedInstance;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if(self) {
        
        AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [serializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        
        [self setRequestSerializer:serializer];
    }
    return self;
}


#pragma mark error handling


- (void)handleError : (NSError *)error {
    NSInteger code = [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
    
    NSString *message = nil;
    NSString *title = @"An error has occurred";
    
    if(code >=400 && code < 500) {
        NSDictionary *jsonDictionary = [NSJSONSerialization
                                        JSONObjectWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]
                                        options:0
                                        error:&error];
        if (jsonDictionary[@"error"]) {
            message = jsonDictionary[@"error"][@"message"];
            title = jsonDictionary[@"error"][@"title"];
        }
    }
    
    FCAlertView *alert = [[FCAlertView alloc] init];
    [alert showAlertInWindow:[[UIApplication sharedApplication]keyWindow]
                   withTitle:title withSubtitle:message
             withCustomImage:nil
         withDoneButtonTitle:nil
                  andButtons:nil];
    
    [alert makeAlertTypeWarning];
    

    
}

- (void)setAuthorizationHeader {
    NSString *authToken = [[MEHUserStoreController sharedUserStoreController]authToken];
    [self.requestSerializer setValue:authToken forHTTPHeaderField:kMEHAuthorizationHeaderField];
}

#pragma mark networking requests with Bolts


- (BFTask *)GET:(NSString *)URLString parameters:(id)parameters {
    
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    
    [self GET:URLString parameters:parameters progress:nil
      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [completionSource setResult:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleError:error];
        [completionSource setError:error];
    }];
    
    return completionSource.task;
    
}

- (BFTask *)POST:(NSString *)URLString
      parameters:(id)parameters {
    
    BFTaskCompletionSource *completionSource = [BFTaskCompletionSource taskCompletionSource];
    
    [self POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [completionSource setResult:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleError:error];
        [completionSource setError:error];
    }];
    
    return completionSource.task;
}

@end
