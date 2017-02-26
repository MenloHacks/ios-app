//
//  LargeTimeViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/19/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "LargeTimeViewController.h"

#import "AutolayoutHelper.h"
//#import "MainEventDetailsStoreController.h"
#import "MBCircularProgressBarView.h"
#import "NSDate+Utilities.h"
#import "UIColor+ColorPalette.h"

@interface LargeTimeViewController ()

@property (nonatomic) MBCircularProgressBarView *progressView;
@property (nonatomic) UILabel *progressLabel;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger totalEventLengthInMinutes;

@end

@implementation LargeTimeViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  self.progressView = [[MBCircularProgressBarView alloc]init];
  _progressView.backgroundColor = [UIColor whiteColor];
  [_progressView setProgressAngle:80];
  _progressView.showUnitString = NO;
  _progressView.showValueString = NO;
  _progressView.progressColor = [UIColor emeraldGreen];
  _progressView.progressStrokeColor = [UIColor emeraldGreen];
  
  
  UIView *spacerOne = [UIView new]; UIView *spacerTwo = [UIView new];
  
  [AutolayoutHelper configureView:self.view subViews:NSDictionaryOfVariableBindings(_progressView, spacerOne, spacerTwo)
                      constraints:@[@"X:_progressView.centerX == superview.centerX",
                                    @"X:_progressView.centerY == superview.centerY",
                                    @"H:|-(20@500)-[_progressView]-(20@500)-|",
                                    @"V:|-(20@500)-[_progressView]-(20@500)-|",
                                    @"H:|-(>=20@650)-[_progressView]-(>=20@650)-|",
                                    @"V:|-(>=20@650)-[_progressView]-(>=20@650)-|",
]];
  
  NSLayoutConstraint *ratio = [NSLayoutConstraint constraintWithItem:_progressView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_progressView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
  ratio.priority = UILayoutPriorityRequired;

  [self.view addConstraint:ratio];
  
  _progressLabel = [UILabel new];
  _progressLabel.numberOfLines = 2;
  [AutolayoutHelper configureView:self.progressView subViews:NSDictionaryOfVariableBindings(_progressLabel)
                      constraints:@[@"X:_progressLabel.centerX == superview.centerX",
                                    @"X:_progressLabel.centerY == superview.centerY"]];
  [self setupTimer];
  
//  if(!_startDate) {
//    [[MainEventDetailsStoreController sharedMainEventDetailsStoreController]getEventStartTimeWithCompletion:^(NSDate *date) {
//      self.startDate = date;
//    }];
//  }
//  if(!_endDate) {
//    [[MainEventDetailsStoreController sharedMainEventDetailsStoreController]getEventEndTimeWithCompletion:^(NSDate *date) {
//      self.endDate = date;
//    }];
//  }
  
}


-(void)updateView : (NSTimer *)timer {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self updateProgressLabel];
    [self updateProgressChart];
  });
}

- (void)updateProgressLabel {
    NSDate *currentDate = [NSDate date];
    if(!_startDate || !_endDate) {
      NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:@"Loading..."];
      [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:24]
                  range:NSMakeRange(0, string.length)];
      _progressLabel.attributedText = string;
      return;
    }
    if([currentDate compare:_endDate] == NSOrderedDescending || [currentDate compare:_endDate] == NSOrderedSame) {
      NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:@"Hacking is over."];
      [string addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:24]
                     range:NSMakeRange(0, string.length)];
      _progressLabel.attributedText = string;
      return;
    }
    NSString *timeUntil;
    NSString *caption;
    if([currentDate compare: _startDate] == NSOrderedAscending) {
        timeUntil = [NSDate formattedTimeUntilDate:_startDate fromDate:currentDate];
        caption = @"until hacking begins";
    } else {
        timeUntil = [NSDate formattedTimeUntilDate:_endDate fromDate:currentDate];
        caption = @"until hacking ends";
    }
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
  
    NSMutableAttributedString *one = [[NSMutableAttributedString alloc]initWithString:timeUntil];
    [one addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:32]
                range:NSMakeRange(0,one.length)];
  
  [one addAttribute:NSParagraphStyleAttributeName value:paragraphStyle
              range:NSMakeRange(0,one.length)];
  
    NSMutableAttributedString *two = [[NSMutableAttributedString alloc]initWithString:caption];
    [two addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"AvenirNext-Regular" size:18]
              range:NSMakeRange(0, caption.length)];
    [one appendAttributedString:[[NSAttributedString alloc]initWithString:@"\n"]];
    [one appendAttributedString:two];
    _progressLabel.attributedText = one;
}

-(void)updateProgressChart {
    if(_startDate && _endDate) {
      NSDate *currentDate = [NSDate date];
      if ([currentDate compare:_endDate] == NSOrderedDescending) {
        [_progressView setValue:100];
      }
      else if ([currentDate compare: _startDate] == NSOrderedAscending) {
        [_progressView setValue:0];
      }
      else {
        NSTimeInterval seconds = [currentDate timeIntervalSinceDate:_startDate];
        NSInteger minutesElapsed = seconds/60;
        CGFloat ratio = 1.0f * minutesElapsed/_totalEventLengthInMinutes;
        [_progressView setValue:100.0f * ratio];
      }
      
    }
  
    else {
      [_progressView setValue:0];
    }
  
}

-(void)setupTimer {
  NSDateComponents *components = [[NSCalendar currentCalendar] components: NSCalendarUnitSecond fromDate:[NSDate date]];
  NSInteger second = [components second];
  NSInteger tillNextMinute;
  if (second == 0) {
    tillNextMinute = 0;
  } else {
    tillNextMinute = (60 - second);
  }
  [self updateView:nil];
  [self performSelector:@selector(startTimer:) withObject:nil afterDelay:tillNextMinute];
}


-(void)startTimer : (NSObject *)object {
  [self updateView:nil];
  _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateView:) userInfo:nil
                                           repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)exit : (UIButton *)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}



@end
