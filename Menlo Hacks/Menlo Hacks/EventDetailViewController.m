//
//  EventDetailViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/24/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "EventDetailViewController.h"

#import "AutolayoutHelper.h"
#import "NSDate+Utilities.h"
#import "UIColor+ColorPalette.h"

#import "MEHEvent.h"
#import "MEHLocation.h"

@import EventKit;
@import EventKitUI;

@interface EventDetailViewController () <UIScrollViewDelegate, EKEventEditViewDelegate>

@property (nonatomic, strong) UIImageView *mapImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton * addToCalendarButton;
@property (nonatomic, strong) UIScrollView *mapImageViewScrollView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation EventDetailViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  UIFont *standardTitleFont = [UIFont fontWithName:@"AvenirNext" size:18.0f];
  self.mapImageView = [[UIImageView alloc]init];
  self.mapImageView.contentMode = UIViewContentModeScaleAspectFit;
  self.timeLabel = [UILabel new];
  self.timeLabel.font = standardTitleFont;
  self.descriptionTextView = [[UITextView alloc]init];
  self.descriptionTextView.font = [UIFont fontWithName:@"AvenirNext" size:14.0f];
  self.descriptionTextView.textColor = [UIColor blackColor];
  self.descriptionTextView.editable = NO;
  self.descriptionLabel = [UILabel new];
  self.descriptionLabel.textColor = [UIColor menloHacksPurple];
  self.descriptionLabel.font = standardTitleFont;
  self.locationLabel = [UILabel new];
  self.locationLabel.font = [UIFont fontWithName:@"AvenirNext" size:18.0f];
  self.addToCalendarButton = [[UIButton alloc]init];
  
  [self.addToCalendarButton setTitle:@"Add Event to Calendar" forState:UIControlStateNormal];
  self.addToCalendarButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext" size:18.0f];
  [self.addToCalendarButton setTitleColor:[UIColor menloHacksPurple] forState:UIControlStateNormal];
  [self.addToCalendarButton addTarget:self
                               action:@selector(addToCalendar:)
                            forControlEvents:UIControlEventTouchDown];
  
  self.mapImageViewScrollView = [[UIScrollView alloc]init];
  self.mapImageViewScrollView.delegate = self;
  self.mapImageViewScrollView.maximumZoomScale = 3.0;
  self.mapImageViewScrollView.minimumZoomScale = 1.0;
  

  _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _loadingView.color = [UIColor menloHacksPurple];
  
  [AutolayoutHelper configureView:self.view
                         subViews:NSDictionaryOfVariableBindings(_mapImageViewScrollView, _timeLabel, _descriptionTextView, _descriptionLabel, _addToCalendarButton, _locationLabel)
                          constraints:@[@"H:|[_mapImageViewScrollView]|",
                                        @"V:|[_mapImageViewScrollView]-[_descriptionLabel]-[_locationLabel]-[_timeLabel]-[_descriptionTextView]-15-[_addToCalendarButton]-75-|",
                                        @"X:_locationLabel.centerX == superview.centerX",
                                        @"X:_descriptionLabel.centerX == superview.centerX",
                                        @"X:_addToCalendarButton.centerX == superview.centerX",
                                        @"X:_timeLabel.centerX == superview.centerX",
                                        @"H:|-[_descriptionTextView]-|"]];
  
  [AutolayoutHelper configureView:_mapImageViewScrollView
                         subViews:NSDictionaryOfVariableBindings(_mapImageView, _loadingView)
                         constraints:@[@"H:|[_mapImageView]|",
                                       @"X:_mapImageView.centerY == superview.centerY",
                                       @"X:_loadingView.centerX == superview.centerX",
                                       @"X:_loadingView.centerY == superview.centerY"]];
  
  NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_mapImageView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:_mapImageViewScrollView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1
                                                                      constant:0];
  
  NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_mapImageView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationLessThanOrEqual
                                                                         toItem:_mapImageViewScrollView
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1
                                                                       constant:0];
  
  [self.view addConstraint:widthConstraint];
  [self.view addConstraint:heightConstraint];
  
  NSLayoutConstraint *scrollViewAspectRatio = [NSLayoutConstraint constraintWithItem:self.mapImageViewScrollView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.mapImageViewScrollView
                                                                           attribute:NSLayoutAttributeWidth
                                                                            multiplier:.75
                                                                            constant:0];
  [self.view addConstraint:scrollViewAspectRatio];
  
  
  if(_event) {
    [self setEvent:_event];
  }
  
  
}

-(void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

-(void)setEvent:(Event *)event {
//  _event = event;
//  EventLocation *location = event.location;
//  self.mapImageView.file = location.map_image;
//  _loadingView.hidden = NO;
//  [_loadingView startAnimating];
//  [self.mapImageView loadInBackground:^(UIImage * _Nullable image, NSError * _Nullable error) {
//    [_loadingView stopAnimating];
//    _loadingView.hidden = YES;
//  }];
//  NSString *timeText;
//  if(event.end_time) {
//    self.addToCalendarButton.hidden = NO;
//    timeText = [NSString stringWithFormat:@"%@ - %@", [NSDate formattedShortTimeFromDate:event.start_time], [NSDate formattedShortTimeFromDate:event.end_time]];
//  }
//  else {
//    timeText = [NSDate formattedShortTimeFromDate:event.start_time];
//    self.addToCalendarButton.hidden = YES;
//  }
//  self.timeLabel.text = timeText;
//  self.locationLabel.text = [NSString stringWithFormat:@"Location: %@", event.location.location_name];
//  self.descriptionTextView.text = event.long_description;
//  self.descriptionLabel.text = event.short_description;

}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return _mapImageView;
}

-(void)addToCalendar: (UIButton *)sender {
//  EKEventStore * eventStore = [[EKEventStore alloc] init];
//  [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
//    if(granted) {
//      EKEvent *event = [EKEvent eventWithEventStore:eventStore];
//      event.title = self.event.short_description;
//      
//      event.location = self.event.location.location_name;
//      event.startDate = self.event.start_time;
//      event.endDate = self.event.end_time;
//      
//      [event setCalendar:[eventStore defaultCalendarForNewEvents]];
//      
//      EKEventEditViewController *eventViewController = [[EKEventEditViewController alloc] init];
//      eventViewController.event = event;
//      eventViewController.eventStore = eventStore;
//      eventViewController.editViewDelegate = self;
//      [self presentViewController:eventViewController animated:YES completion:nil];
//    }
//    else {
//      
//    }
//  }];
  
}

- (void)eventEditViewController:(EKEventEditViewController *)controller
          didCompleteWithAction:(EKEventEditViewAction)action {
  
  [self dismissViewControllerAnimated:YES completion:nil];
}




@end
