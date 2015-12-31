//
//  TimeView.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "TimeView.h"

#import "AutolayoutHelper.h"
#import "NSDate+Utilities.h"
#import "UIFontDescriptor+AvenirNext.h"

@interface TimeView()

@property (nonatomic, strong) UILabel *timeLeftLabel;
@property (nonatomic, strong) NSLayoutConstraint *coloringWidth;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger totalEventLengthInMinutes;

@end

@implementation TimeView

-(id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  [self commonInit];
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  [self commonInit];
  return self;
}

-(void)commonInit {
  UIColor *progressColor = [UIColor blueColor];
  self.backgroundColor = [UIColor redColor];
  UIView *progressView = [UIView new];
  progressView.backgroundColor = progressColor;
  [AutolayoutHelper configureView:self subViews:VarBindings(progressView) constraints:
                                                                          @[@"V:|[progressView]|"]];
  
  self.coloringWidth = [NSLayoutConstraint constraintWithItem:progressView attribute:NSLayoutAttributeWidth
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeWidth
                                                   multiplier:0
                                                     constant:0];
  [self addConstraint:_coloringWidth];
  
  _timeLeftLabel = [UILabel new];
  _timeLeftLabel.textColor = [UIColor whiteColor];
//  _timeLeftLabel.backgroundColor = [UIColor greenColor];
  _timeLeftLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
                         
  [AutolayoutHelper configureView:self subViews:VarBindings(_timeLeftLabel)
                      constraints:@[@"X:_timeLeftLabel.centerX == superview.centerX",
                                    @"X:_timeLeftLabel.centerY == superview.centerY"]];
  [self setupTimer];

}

-(void)updateView : (NSTimer *)timer {
  dispatch_async(dispatch_get_main_queue(), ^{
    _timeLeftLabel.text = [self getDisplayString];
    [self updateProgressWidth];
  });
}

-(void)updateProgressWidth {
  if(_startDate && _endDate) {
    NSDate *currentDate = [NSDate date];
    if ([currentDate compare:_endDate] == NSOrderedDescending) {
      _coloringWidth.constant = self.frame.size.width;
    }
    else if ([currentDate compare: _startDate] == NSOrderedAscending) {
      _coloringWidth.constant = 0;
    }
    else {
      NSTimeInterval seconds = [currentDate timeIntervalSinceDate:_endDate];
      NSInteger minutesElapsed = seconds/60;
      CGFloat ratio = minutesElapsed/_totalEventLengthInMinutes;
      _coloringWidth.constant = self.frame.size.width * ratio;
    }
 
  }
}

-(NSString *)getDisplayString {
  NSDate *currentDate = [NSDate date];
  if(!_startDate || !_endDate) {
    return @"Loading...";
  }
  if([currentDate compare:_endDate] == NSOrderedDescending) {
    return @"Hacking is over.";
  }
  else if([currentDate compare: _startDate] == NSOrderedAscending) {
    NSString *timeUntil = [NSDate formattedTimeUntilDate:_startDate fromDate:currentDate];
    return [NSString stringWithFormat:@"%@ until hacking begins", timeUntil];
  }
  else {
    NSString *timeUntil = [NSDate formattedTimeUntilDate:_startDate fromDate:currentDate];
    return [NSString stringWithFormat:@"%@ until hacking ends", timeUntil];
  }
  
}

-(void)setupTimer {
  NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitSecond fromDate:[NSDate date]];
  NSInteger second = [components second];
  NSInteger tillNextMinute = (60 - second);
  [self performSelector:@selector(startTimer:) withObject:nil afterDelay:tillNextMinute];
}


-(void)startTimer : (NSObject *)object {
  [self updateView:nil];
  _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateView:) userInfo:nil
                                          repeats:YES];
}

-(void)drawRect:(CGRect)rect {
  [self updateProgressWidth];
}

-(void)setStartDate:(NSDate *)startDate {
  _startDate = startDate;
  if(_endDate) {
    _totalEventLengthInMinutes = ([_endDate timeIntervalSinceDate:_startDate] / 60);
    [self updateView:nil];
  }
}

-(void)setEndDate:(NSDate *)endDate {
  _endDate = endDate;
  if(_startDate) {
    _totalEventLengthInMinutes = ([_endDate timeIntervalSinceDate:_startDate] / 60);
    [self updateView:nil];
  }
}
@end
