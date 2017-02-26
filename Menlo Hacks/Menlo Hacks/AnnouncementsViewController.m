//
//  AnnouncementsViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/31/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "AnnouncementsViewController.h"

#import "AutolayoutHelper.h"
#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"

#import "MEHAnnouncement.h"
#import "AnnouncementsStoreController.h"
#import "InfoTableViewCell.h"
//#import "MainEventDetailsStoreController.h"
#import "TimeView.h"


@interface AnnouncementsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic) int numberOfEntriesInSchedule;
@property (nonatomic, strong) NSArray<Announcement *> *annoucements;
@property (nonatomic, strong) UILabel *noAnnouncementsLabel;
@property (nonatomic, strong) UIRefreshControl *refresh;

@end

static NSString *reuseIdentifier = @"com.menlohacks.announcement";

@implementation AnnouncementsViewController

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
  
//  [[MainEventDetailsStoreController sharedMainEventDetailsStoreController]getEventStartTimeWithCompletion:^(NSDate *date) {
//    timeView.startDate = date;
//  }];
//  
//  [[MainEventDetailsStoreController sharedMainEventDetailsStoreController]getEventEndTimeWithCompletion:^(NSDate *date) {
//    timeView.endDate = date;
//  }];
  
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
  [[AnnouncementsStoreController sharedAnnouncementsStoreController]getAnnouncements:^(NSArray<Announcement *> *results) {
    _annoucements = results;
    [_loadingView stopAnimating];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _loadingView.hidden = YES;
    _tableView.hidden = NO;
    [_tableView reloadData];
  }];
}

-(void)addRefreshView {
  _refresh = [[UIRefreshControl alloc] init];
  _refresh.tintColor = [UIColor menloHacksPurple];
  [_refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
  [self.tableView addSubview:_refresh];
}

- (void)refresh : (UIRefreshControl *)sender {
  [[AnnouncementsStoreController sharedAnnouncementsStoreController]getAnnouncements:^(NSArray<Announcement *> *results) {
    _annoucements = results;
    dispatch_async(dispatch_get_main_queue(), ^{
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
      // reload tableView after refresh control finish refresh animation
      [self.tableView reloadData];
    }];
    [sender endRefreshing];
    [CATransaction commit];
    });
  }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  InfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  [cell configureWithAnnouncement:_annoucements[indexPath.row]];
  return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if([_annoucements count] > 0) {
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
  return [_annoucements count];
}
@end
