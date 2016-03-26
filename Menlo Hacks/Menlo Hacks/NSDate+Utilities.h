//
//  NSDate+Utilities.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utilities)

+ (NSString *)formattedTimeUntilDate : (NSDate *)toDate fromDate: (NSDate *)fromDate;
+ (NSString *)formattedShortTimeFromDate : (NSDate *)date;
+ (NSString *)formattedDayOftheWeekFromDate : (NSDate *)date;

@end
