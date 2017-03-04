//
//  MEHUser.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/3/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <Realm/Realm.h>

@interface MEHUser : RLMObject

@property NSString *username;
@property NSString *name;

+ (instancetype)userFromDictionary : (NSDictionary *)dictionary;

//TODO: Mentorship stuff.


@end

// This protocol enables typed collections. i.e.:
// RLMArray<MEHUser *><MEHUser>
RLM_ARRAY_TYPE(MEHUser)
