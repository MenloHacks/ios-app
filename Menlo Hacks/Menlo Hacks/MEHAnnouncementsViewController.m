//
//  AnnouncementsViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/31/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "MEHAnnouncementsViewController.h"

#import "AutolayoutHelper.h"
#import <Bolts/Bolts.h>
#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"

#import "MEHAnnouncement.h"
#import "MEHAnnouncementsStoreController.h"
#import "MEHEventTimingStoreController.h"
#import "InfoTableViewCell.h"
#import "TimeView.h"


@interface MEHAnnouncementsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic) int numberOfEntriesInSchedule;
@property (nonatomic, strong) RLMResults *announcements;
@property (nonatomic, strong) UILabel *noAnnouncementsLabel;
@property (nonatomic, strong) UIRefreshControl *refresh;

@property (nonatomic, strong) RLMNotificationToken *notificationToken;

@property (nonatomic) NSInteger nextIndex;
@property (nonatomic) BOOL isLoading;

@end

static NSString *reuseIdentifier = @"com.menlohacks.announcement";
static NSInteger kMEHPageSize = 25;

@implementation MEHAnnouncementsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  self.tableView = [[UITableView alloc]init];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.allowsSelection = NO;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.estimatedRowHeight = 40;
   self.tableView.tableFooterView = [UIView new];
  [_tableView registerClass:[InfoTableViewCell class] forCellReuseIdentifier:reuseIdentifier];
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
  
  _noAnnouncementsLabel = [UILabel new];
  _noAnnouncementsLabel.textColor = [UIColor lightGrayColor];
  _noAnnouncementsLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
  _noAnnouncementsLabel.numberOfLines = 0;
  
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_noAnnouncementsLabel)
                      constraints: @[@"H:|-[_noAnnouncementsLabel]-|",
                                     @"X:_noAnnouncementsLabel.centerY == superview.centerY"]];
  
  _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _loadingView.color = [UIColor menloHacksPurple];
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_loadingView)
                      constraints: @[@"X:_loadingView.centerX == superview.centerX",
                                     @"X:_loadingView.centerY == superview.centerY"]];
  [self forceRefresh];
  
}
- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  _noAnnouncementsLabel.text = @"";
  [self forceRefresh];
}

- (void)forceRefresh {
    [_loadingView startAnimating];
    _tableView.hidden = YES;
    self.nextIndex = 0;
    [[[MEHAnnouncementsStoreController sharedAnnouncementsStoreController]fetchAnnouncementsWithStart:self.nextIndex andCount:kMEHPageSize]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        self.announcements = [[MEHAnnouncementsStoreController sharedAnnouncementsStoreController]announcements];

        dispatch_async(dispatch_get_main_queue(), ^{
            [_loadingView stopAnimating];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            _loadingView.hidden = YES;
            _tableView.hidden = NO;
            [_tableView reloadData];
        });
        return nil;
    }];
    
}

-(void)addRefreshView {
  _refresh = [[UIRefreshControl alloc] init];
  _refresh.tintColor = [UIColor menloHacksPurple];
  [_refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
  [self.tableView addSubview:_refresh];
}

- (void)refresh : (UIRefreshControl *)sender {
    
    [[[MEHAnnouncementsStoreController sharedAnnouncementsStoreController]fetchAnnouncementsWithStart:self.nextIndex andCount:kMEHPageSize]continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        self.announcements = [[MEHAnnouncementsStoreController sharedAnnouncementsStoreController]announcements];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                // reload tableView after refresh control finish refresh animation
                [self.tableView reloadData];
            }];
            [sender endRefreshing];
            [CATransaction commit];
        });
        return nil;
    }];

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  [cell configureWithAnnouncement:_announcements[indexPath.row]];
  return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if(_announcements.count > 0) {
    _noAnnouncementsLabel.text = @"";
    if(!_refresh.superview) {
         [self addRefreshView]; 
    }
  }
  else if (_loadingView.hidden == YES) /*checking to make sure the loading view is hidden avoids the message from showing on launch*/ {
    _noAnnouncementsLabel.text = @"No announcements have been made so far. You'll recieve a notification when we have something to say";
    if(_refresh.superview) {
      [_refresh removeFromSuperview];
    }
  }
    return _announcements.count;
}

- (void)setAnnouncements:(RLMResults *)announcements {
    _announcements = announcements;
    __weak typeof(self) weakSelf = self;
    self.notificationToken = [_announcements addNotificationBlock:^(RLMResults *results, RLMCollectionChange *changes, NSError *error) {
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
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:[changes deletionsInSection:0]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[changes insertionsInSection:0]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView reloadRowsAtIndexPaths:[changes modificationsInSection:0]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
        });

    }];
}

@end
