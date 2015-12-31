//
//  ScheduleViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "ScheduleViewController.h"

#import "AutolayoutHelper.h"
#import <Parse/Parse.h>
#import "UIColor+ColorPalette.h"

#import "MainEventDetailsStoreController.h"
#import "TimeView.h"
#import "Event.h"
#import "ScheduleStoreController.h"
#import "EventTableViewCell.h"

@interface ScheduleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic) int numberOfEntriesInSchedule;
@property (nonatomic, strong) NSArray<Event *> *events;

@end

static int timeViewHeight = 50;
static NSString *reuseIdentifier = @"com.menlohacks.event";

@implementation ScheduleViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  self.tableView = [[UITableView alloc]init];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.estimatedRowHeight = 40;
//  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [_tableView registerClass:[EventTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
  TimeView *timeView = [[TimeView alloc]init];
  
  [[MainEventDetailsStoreController sharedMainEventDetailsStoreController]getEventStartTimeWithCompletion:^(NSDate *date) {
    timeView.startDate = date;
  }];
  
  [[MainEventDetailsStoreController sharedMainEventDetailsStoreController]getEventEndTimeWithCompletion:^(NSDate *date) {
    timeView.endDate = date;
  }];
  
  NSNumber *timeViewHeightNum = @(timeViewHeight);

  [AutolayoutHelper configureView:self.view subViews:VarBindings(_tableView, timeView)
                          metrics:VarBindings(timeViewHeightNum)
                      constraints:@[@"V:|[timeView(timeViewHeightNum)][_tableView]|",
                                    @"H:|[_tableView]|",
                                    @"H:|[timeView]|"]];
  
  _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _loadingView.color = [UIColor menloBlue];
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_loadingView)
                      constraints: @[@"X:_loadingView.centerX == superview.centerX",
                                     @"X:_loadingView.centerY == superview.centerY"]];
  [_loadingView startAnimating];
  
  [[ScheduleStoreController sharedScheduleStoreController]getScheduleItems:^(NSArray<Event *> *results) {
    _events = results;
    [_loadingView stopAnimating];
    _loadingView.hidden = YES;
    [_tableView reloadData];
  }];
  
  
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  [cell configureWithEvent:_events[indexPath.row]];
  return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_events count];
}

@end
