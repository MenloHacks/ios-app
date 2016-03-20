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
#import "InfoTableViewCell.h"

@interface ScheduleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic) int numberOfEntriesInSchedule;
@property (nonatomic, strong) NSArray<Event *> *events;

@end

static NSString *reuseIdentifier = @"com.menlohacks.event";

@implementation ScheduleViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  self.tableView = [[UITableView alloc]init];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.allowsSelection = NO;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.tableFooterView = [UIView new];
  self.tableView.estimatedRowHeight = 40;
  [_tableView registerClass:[InfoTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
  TimeView *timeView = [[TimeView alloc]init];
  
  [[MainEventDetailsStoreController sharedMainEventDetailsStoreController]getEventStartTimeWithCompletion:^(NSDate *date) {
    timeView.startDate = date;
  }];
  
  [[MainEventDetailsStoreController sharedMainEventDetailsStoreController]getEventEndTimeWithCompletion:^(NSDate *date) {
    timeView.endDate = date;
  }];
  
  NSNumber *timeViewHeightNum = @(standardTimeViewHeight);

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
  
  UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
  refresh.tintColor = [UIColor menloBlue];
  [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
  [self.tableView addSubview:refresh];
  
  [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self refresh];
}

- (void)refresh : (UIRefreshControl *)sender {
  [[ScheduleStoreController sharedScheduleStoreController]getScheduleItems:^(NSArray<Event *> *results) {
    _events = results;
    dispatch_async(dispatch_get_main_queue(), ^{
      [CATransaction begin];
      [CATransaction setCompletionBlock:^{
        // reload tableView after refresh control finish refresh animation
          [self.tableView reloadData];
          [self scrollToNextEvent];
      }];
      [sender endRefreshing];
      [CATransaction commit];
      
    });
  }];
}

- (void)refresh {
  _tableView.hidden = YES;
  [_loadingView startAnimating];
  [[ScheduleStoreController sharedScheduleStoreController]getScheduleItems:^(NSArray<Event *> *results) {
    _events = results;
     dispatch_async(dispatch_get_main_queue(), ^{
       [_loadingView stopAnimating];
       _tableView.hidden = NO;
       self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
       _loadingView.hidden = YES;
       [_tableView reloadData];
       [self scrollToNextEvent];
     });
  }];
}

/* Precondition: Based on the sort order the scheduled events should be sorted. */
-(void)scrollToNextEvent {
  NSDate *currentDate = [NSDate date];
  for (int i = 0; i < [_events count]; i++){
    NSDate *contender = _events[i].time;
    if([contender compare:currentDate] == NSOrderedDescending) {
      [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
      return;
    }
  }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  [cell configureWithEvent:_events[indexPath.row]];
  return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_events count];
}

@end
