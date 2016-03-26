//
//  ScheduleViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "ScheduleViewController.h"

#import "AutolayoutHelper.h"
#import "NSDate+Utilities.h"
#import <Parse/Parse.h>
#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"

#import "EventDetailViewController.h"
#import "MainEventDetailsStoreController.h"
#import "TimeView.h"
#import "Event.h"
#import "ScheduleStoreController.h"
#import "InfoTableViewCell.h"

@interface ScheduleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic) int numberOfEntriesInSchedule;
@property (nonatomic, strong) NSArray <NSArray<Event *> *> *events;

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
}

- (void)refresh : (UIRefreshControl *)sender {
  [[ScheduleStoreController sharedScheduleStoreController]getScheduleItems:^(NSArray<Event *> *results) {
    [self convertEventsIntoSegmentedArray:results];
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
    [self convertEventsIntoSegmentedArray:results];
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
  for (int i = 0; i < [_events count]; i++) {
    for (int j = 0; j < _events[i].count; j++) {
      NSDate *contender = _events[i][j].start_time;
      if([contender compare:currentDate] == NSOrderedDescending) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:j inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return;
      }
    }
    

  }
}

/*Precondition: Events array is sorted */
-(void)convertEventsIntoSegmentedArray : (NSArray <Event *> *)events {
  NSMutableArray <NSMutableArray<Event *> *> * segmentedEvents = [[NSMutableArray alloc]init];
  if(events.count > 0) {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    int i = 0;
    NSMutableArray *array = [[NSMutableArray alloc]init];
    [segmentedEvents addObject:array];
    NSDateComponents *statusQuo = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:events[0].start_time];
    for (Event *event in events) {
      NSDateComponents *contender = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay fromDate:event.start_time];
      if(contender.day != statusQuo.day || contender.month != statusQuo.month || contender.year != statusQuo.year) {
        statusQuo = contender;
        i++;
        NSMutableArray *array = [[NSMutableArray alloc]init];
        [array addObject:event];
        [segmentedEvents addObject:array];
      }
      else {
        NSMutableArray *array = segmentedEvents[i];
        [array addObject:event];
        segmentedEvents[i] = array;
      }
    }
  }
  _events = segmentedEvents;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UILabel *label = [UILabel new];
  label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14.0f];
  label.text = [self tableView:tableView titleForHeaderInSection:section];
  UIView *parentView = [UIView new];
  parentView.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
  [AutolayoutHelper configureView:parentView
                      subViews:NSDictionaryOfVariableBindings(label)
                      constraints:@[@"H:|-[label]",
                                    @"X:label.centerY == superview.centerY"]];
  return parentView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  [cell configureWithEvent:_events[indexPath.section][indexPath.row]];
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  EventDetailViewController *vc = [[EventDetailViewController alloc]init];
  vc.navigationController.navigationBar.topItem.titleView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"menlo_hacks_logo_blue_nav"]];
  vc.event = self.events[indexPath.section][indexPath.row];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if(section >= _events.count) {
    return @"";
  }
  return [NSDate formattedDayOftheWeekFromDate:_events[section][0].start_time];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _events[section].count;
  
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _events.count;
}


@end
