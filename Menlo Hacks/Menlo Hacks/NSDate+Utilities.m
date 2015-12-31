//
//  NSDate+Utilities.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

+ (NSString *)formattedTimeUntilDate : (NSDate *)toDateTime fromDate: (NSDate *)fromDateTime {
  
  NSDate *fromDate;
  NSDate *toDate;

  NSCalendar *calendar = [NSCalendar currentCalendar];
  
  [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
               interval:NULL forDate:fromDateTime];
  [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
               interval:NULL forDate:toDateTime];
  
  NSDateComponents *difference = [calendar components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute
                                             fromDate:fromDate toDate:toDate options:0];
  
  if ([difference day] > 1) {
    return [NSString stringWithFormat:@"%li days", (long)[difference day]];
  }
  else if ([difference day] == 1) {
     return [NSString stringWithFormat:@"%li day", (long)[difference day]];
  }
  else if ([difference minute] >= 1) {
    return [NSString stringWithFormat:@"%li:%li", [difference hour], [difference minute]];
  }
  else {
    return @"";
  }
}

+ (NSString *)formattedShortTimeFromDate : (NSDate *)date {
  static dispatch_once_t once;
  static NSDateFormatter *_sharedInstance;
  dispatch_once(&once, ^{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    _sharedInstance = dateFormatter;
  });
  
  return [_sharedInstance stringFromDate:date];
}

@end
