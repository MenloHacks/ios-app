//
//  ScheduleViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/29/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "MEHScheduleViewController.h"

#import <Bolts/Bolts.h>

#import "AutolayoutHelper.h"
#import "NSDate+Utilities.h"
#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"

#import "MEHEventDetailViewController.h"
#import "MEHEventTimingStoreController.h"
#import "TimeView.h"
#import "MEHEvent.h"
#import "MEHScheduleStoreController.h"
#import "InfoTableViewCell.h"

@interface MEHScheduleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) NSArray<RLMResults<MEHEvent *> *>*events;
@property (nonatomic, strong) NSArray <RLMNotificationToken *>*notificationTokens;

@end

static NSString *KMEHEventReuseIdentifier = @"com.menlohacks.tableview.event";


@implementation MEHScheduleViewController

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

  self.parentViewController.navigationItem.rightBarButtonItems = @[];
    
  [_tableView registerClass:[InfoTableViewCell class] forCellReuseIdentifier:KMEHEventReuseIdentifier];
  TimeView *timeView = [[TimeView alloc]init];
    
    [[[MEHEventTimingStoreController sharedTimingStoreController]hackingStartTime]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        timeView.startDate = t.result;
        return nil;
    }];
    
    [[[MEHEventTimingStoreController sharedTimingStoreController]hackingEndTime]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        timeView.endDate = t.result;
        return nil;
    }];
  

  NSNumber *timeViewHeightNum = @(standardTimeViewHeight);

  [AutolayoutHelper configureView:self.view subViews:VarBindings(_tableView, timeView)
                          metrics:VarBindings(timeViewHeightNum)
                      constraints:@[@"V:|[timeView(timeViewHeightNum)][_tableView]|",
                                    @"H:|[_tableView]|",
                                    @"H:|[timeView]|"]];
  
  _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _loadingView.color = [UIColor menloHacksPurple];
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_loadingView)
                      constraints: @[@"X:_loadingView.centerX == superview.centerX",
                                     @"X:_loadingView.centerY == superview.centerY"]];
  
  UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
  refresh.tintColor = [UIColor menloHacksPurple];
  [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
  [self.tableView addSubview:refresh];
  
  [self refresh];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  self.parentViewController.navigationItem.rightBarButtonItems = @[];
}

- (void)refresh : (UIRefreshControl *)sender {
    
    [[[MEHScheduleStoreController sharedScheduleStoreController]fetchScheduleItems]continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [[[MEHScheduleStoreController sharedScheduleStoreController]events]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
            self.events = t.result;
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
            
            return nil;
        }];
        

    }];
    

}

- (void)refresh {
  _tableView.hidden = YES;
  [_loadingView startAnimating];
  [[[MEHScheduleStoreController sharedScheduleStoreController]fetchScheduleItems]continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
      return [[[MEHScheduleStoreController sharedScheduleStoreController]events]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
          self.events = t.result;
          dispatch_async(dispatch_get_main_queue(), ^{
              [_loadingView stopAnimating];
              _tableView.hidden = NO;
              self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
              _loadingView.hidden = YES;
              [_tableView reloadData];
              [self scrollToNextEvent];
          });
           return nil;
      }];

     
  }];
    
    
}


/* Precondition: Based on the sort order the scheduled events should be sorted. */
-(void)scrollToNextEvent {
  NSDate *currentDate = [NSDate date];
  for (int i = 0; i < [_events count]; i++) {
    for (int j = 0; j < _events[i].count; j++) {
      NSDate *contender = _events[i][j].startTime;
      if([contender compare:currentDate] == NSOrderedDescending) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:j inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return;
      }
    }
    

  }
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
  InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:KMEHEventReuseIdentifier];
  [cell configureWithEvent:_events[indexPath.section][indexPath.row]];
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  MEHEventDetailViewController *vc = [[MEHEventDetailViewController alloc]init];
  vc.navigationItem.titleView = [[UIImageView alloc]initWithImage:
                                 [UIImage imageNamed:@"menlohacks_nav"]];
  
  vc.event = self.events[indexPath.section][indexPath.row];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if(section >= _events.count) {
    return @"";
  }
    if (_events[section].count > 0) {
        return [NSDate formattedDayOftheWeekFromDate:_events[section][0].startTime];
    } else {
        return @"";
    }
  
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _events[section].count;
  
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return _events.count;
}

- (void)setEvents:(NSArray<RLMResults<MEHEvent *> *> *)events {
    _events = events;
    NSMutableArray *tokens = [NSMutableArray arrayWithCapacity:_events.count];
    int i = 0;
    __weak typeof(self) weakSelf = self;
    for (RLMResults *results in events) {
        tokens[i] = [results addNotificationBlock:^(RLMResults *results, RLMCollectionChange *changes, NSError *error) {
            int section = i;
            if (error) {
                NSLog(@"Failed to open Realm on background worker: %@", error);
                return;
            }
            
            UITableView *tableView = weakSelf.tableView;
            
            // Initial run of the query will pass nil for the change information
            if (!changes) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView reloadData];
                });
                return;
            }
            
            // Query results have changed, so apply them to the UITableView
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(changes.insertions.count == 0 &&
                       changes.deletions.count == 0 &&
                       changes.modifications.count == [tableView numberOfRowsInSection:section]) {
                        //We seem to have a problem where realm triggers changes for all things at certain points.
                        //A refresh force reloads and we'll never batch send notifs so this fixes the issue.
                        //hacky, yes––but it works.
                        return;
                    }
                    [tableView beginUpdates];
                    [tableView insertRowsAtIndexPaths:[changes insertionsInSection:section]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                    [tableView deleteRowsAtIndexPaths:[changes deletionsInSection:section]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                    [tableView reloadRowsAtIndexPaths:[changes modificationsInSection:section]
                                         withRowAnimation:UITableViewRowAnimationAutomatic];
                        
                    [tableView endUpdates];
                });

            
        }];
        i++;
    }
    self.notificationTokens = [NSArray arrayWithArray:tokens];
}

- (void)dealloc {
    for (RLMNotificationToken *token in self.notificationTokens) {
        [token stop];
    }
}


@end
