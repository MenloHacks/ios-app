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

#import "Announcement.h"
#import "InfoTableViewCell.h"
#import "TimeView.h"
#import "MainEventDetailsStoreController.h"
#import "AnnouncementsStoreController.h"


@interface AnnouncementsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic) int numberOfEntriesInSchedule;
@property (nonatomic, strong) NSArray<Announcement *> *annoucements;
@property (nonatomic, strong) UILabel *noAnnouncementsLabel;

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
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.estimatedRowHeight = 40;
   self.tableView.tableFooterView = [UIView new];
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
  
  _noAnnouncementsLabel = [UILabel new];
  _noAnnouncementsLabel.textColor = [UIColor lightGrayColor];
  _noAnnouncementsLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
  _noAnnouncementsLabel.numberOfLines = 0;
  
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_noAnnouncementsLabel)
                      constraints: @[@"H:|-[_noAnnouncementsLabel]-|",
                                     @"X:_noAnnouncementsLabel.centerY == superview.centerY"]];
  
  _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _loadingView.color = [UIColor menloBlue];
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_loadingView)
                      constraints: @[@"X:_loadingView.centerX == superview.centerX",
                                     @"X:_loadingView.centerY == superview.centerY"]];
  [_loadingView startAnimating];
  
  
  [[AnnouncementsStoreController sharedAnnouncementsStoreController]getAnnouncements:^(NSArray<Announcement *> *results) {
    _annoucements = results;
    [_loadingView stopAnimating];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _loadingView.hidden = YES;
    [_tableView reloadData];
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
  }
  else if (_loadingView.hidden == YES) /*checking to make sure the loading view is hidden avoids the message from showing on launch*/ {
    _noAnnouncementsLabel.text = @"No announcements have been made so far. You'll recieve a notification when we have something to say";
  }
  return [_annoucements count];
}
@end
