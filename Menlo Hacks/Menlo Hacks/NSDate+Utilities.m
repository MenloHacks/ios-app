//
//  NSDate+Utilities.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

+ (NSString *)formattedTimeUntilDate : (NSDate *)toDate fromDate: (NSDate *)fromDate {

  NSCalendar *calendar = [NSCalendar currentCalendar];
  
  NSDateComponents *difference = [calendar components:NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute
                                             fromDate:fromDate toDate:toDate options:0];
  if ([difference day] > 1) {
    return [NSString stringWithFormat:@"%li days", (long)[difference day]];
  }
  else if ([difference day] == 1) {
     return [NSString stringWithFormat:@"%li day", (long)[difference day]];
  }
  else if ([difference hour] >= 1) {
    if([difference minute] < 10) {
      return [NSString stringWithFormat:@"%li:0%li", [difference hour], [difference minute]];
    }
    else {
      return [NSString stringWithFormat:@"%li:%li", [difference hour], [difference minute]];
    }
  }
  else if ([difference minute] > 1) {
    return [NSString stringWithFormat:@"%li minutes", [difference minute]];
  }
  else if ([difference minute] == 1) {
    return [NSString stringWithFormat:@"%li minute", [difference minute]];
  }
  else {
    return @"1 minute";
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

+ (NSString *)formattedDayOftheWeekFromDate : (NSDate *)date {
  static dispatch_once_t once;
  static NSDateFormatter *_sharedInstance;
  dispatch_once(&once, ^{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    _sharedInstance = dateFormatter;
  });
  
  return [_sharedInstance stringFromDate:date];
}

+ (NSDate*)dateFromISOString : (NSString *)string {
    static dispatch_once_t once;
    static NSDateFormatter *_sharedInstance;
    dispatch_once(&once, ^{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        _sharedInstance = dateFormatter;
    });
    
    return [_sharedInstance dateFromString:string];
}

+ (NSInteger)numberOfDaysBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:firstDate toDate:secondDate options:0];
    return [components day]+1;
}



- (NSDate *)add24Hours {
    return [self dateByAddingTimeInterval:60*60*24];
}

@end
