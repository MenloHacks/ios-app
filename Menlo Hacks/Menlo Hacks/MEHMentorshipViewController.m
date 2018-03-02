//
//  MEHMentorshipViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHMentorshipViewController.h"

#import "AutolayoutHelper.h"
#import <Bolts/Bolts.h>
#import <Realm/Realm.h>
#import "SCLAlertView.h"

#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"
#import "UIViewController+Extensions.h"

#import "MEHErrorCodes.h"
#import "MEHLoginViewController.h"
#import "MEHMentorTicket.h"
#import "MEHMentorshipStoreController.h"
#import "MEHMentorTicketTableViewCell.h"
#import "MEHUserStoreController.h"

@interface MEHMentorshipViewController () <UITableViewDelegate, UITableViewDataSource,
MEHMentorTicketTableViewCellDelegate, MEHLoginViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) NSArray<RLMResults<MEHMentorTicket *> *>*tickets;
@property (nonatomic, strong) NSArray <RLMNotificationToken *>*notificationTokens;
@property (nonatomic, strong) NSArray<NSNumber *> *nonEmptyTicketIndices;

@property (nonatomic, strong) UILabel *noTicketsLabel;

@property (nonatomic) MEHMentorAction pendingAction;
@property (nonatomic, strong) NSString *pendingActionTicket;

@property (nonatomic, strong) MEHLoginViewController *loginVC;

@end

static NSString * kMEHMentorTicketReuseIdentifier = @"com.menlohacks.mentorship.ticket.cell";

@implementation MEHMentorshipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 150;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.tableView registerClass:[MEHMentorTicketTableViewCell class] forCellReuseIdentifier:kMEHMentorTicketReuseIdentifier];
    
    [AutolayoutHelper configureView:self.view fillWithSubView:self.tableView];
    
    
    _noTicketsLabel = [UILabel new];
    _noTicketsLabel.textColor = [UIColor lightGrayColor];
    _noTicketsLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
    _noTicketsLabel.numberOfLines = 0;
    _noTicketsLabel.text = @"No tickets are available.";
    _noTicketsLabel.hidden = YES;
    _noTicketsLabel.textAlignment = NSTextAlignmentCenter;
    
    [AutolayoutHelper configureView:self.view subViews:VarBindings(_noTicketsLabel)
                        constraints: @[@"H:|-[_noTicketsLabel]-|",
                                       @"X:_noTicketsLabel.centerY == superview.centerY"]];
    
    _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingView.color = [UIColor menloHacksPurple];
    [AutolayoutHelper configureView:self.view subViews:VarBindings(_loadingView)
                        constraints: @[@"X:_loadingView.centerX == superview.centerX",
                                       @"X:_loadingView.centerY == superview.centerY"]];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor menloHacksPurple];
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    
    if(self.requiresLogin && ![[MEHUserStoreController sharedUserStoreController]isUserLoggedIn]) {
        self.loginVC = [[MEHLoginViewController alloc]init];
        self.loginVC.delegate = self;
        [self displayContentController:self.loginVC];
    } else {
        [self refresh];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(self.requiresLogin && ![[MEHUserStoreController sharedUserStoreController]isUserLoggedIn]) {
        if(!self.loginVC) {
            self.loginVC = [[MEHLoginViewController alloc]init];
            self.loginVC.delegate = self;
            [self displayContentController:self.loginVC];
        }
    } else {
        if(self.loginVC) {
            [self removeContentViewController:self.loginVC];
        }
    }
    if(self.pendingActionTicket) {
        [self handleAction:self.pendingAction forTicketWithServerID:self.pendingActionTicket];
    }
}

- (void)refresh : (id)sender {
    [self.fetchFromServer()continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        [self resetTickets];
        dispatch_async(dispatch_get_main_queue(), ^{
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [self.tableView reloadData];
            }];
            [sender endRefreshing];
            [CATransaction commit];
        });

        
        return nil;
    }];
}

- (void)refresh {
    _tableView.hidden = YES;
    [_loadingView startAnimating];
    
    [self.fetchFromServer()continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        [self resetTickets];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_loadingView stopAnimating];
            _tableView.hidden = NO;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            _loadingView.hidden = YES;
            [_tableView reloadData];
        });


        return nil;
    }];
    
}

- (void)resetTickets {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.predicates.count];
    for (NSPredicate *predicate in self.predicates) {
        RLMResults *results = [[MEHMentorTicket objectsWithPredicate:predicate]sortedResultsUsingKeyPath:@"timeCreated" ascending:YES];
        [array addObject:results];
    }
    self.tickets = [NSArray arrayWithArray:array];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSMutableArray *nonEmptyIndices = [NSMutableArray array];
    if(self.tickets.count > 0) {
        int i = 0;
        for (RLMResults *results in self.tickets) {
            if (results.count > 0) {
                [nonEmptyIndices addObject:@(i)];
            }
            i++;
        }
    }
    self.nonEmptyTicketIndices = [NSArray arrayWithArray:nonEmptyIndices];
        
    _noTicketsLabel.hidden = (self.nonEmptyTicketIndices.count > 0);
    return self.nonEmptyTicketIndices.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger index = self.nonEmptyTicketIndices[section].integerValue;
    return self.tickets[index].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = self.nonEmptyTicketIndices[indexPath.section].integerValue;
    MEHMentorTicketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMEHMentorTicketReuseIdentifier];
    cell.ticket = self.tickets[index][indexPath.row];
    cell.delegate = self;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(self.predicateLabels != nil && self.nonEmptyTicketIndices.count >= 1) {
        
        NSInteger index = self.nonEmptyTicketIndices[section].integerValue;
        if(index < self.predicateLabels.count) {
            UIView *wrapper = [UIView new];
            wrapper.backgroundColor = [UIColor whiteColor];
            
            UILabel *label = [UILabel new];
            label.backgroundColor = [UIColor whiteColor];
            label.text = self.predicateLabels[index];
            label.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0];
            label.textColor = [UIColor menloHacksPurple];
                          
            [AutolayoutHelper configureView:wrapper
                                   subViews:NSDictionaryOfVariableBindings(label)
                                constraints:@[@"H:|[label]|",
                                              @"V:|[label]|"]];
            return wrapper;
        }
        

    }
    return nil;
}


- (void)setTickets:(NSArray<RLMResults<MEHMentorTicket *> *> *)tickets {
    _tickets = tickets;
    
    if(tickets.count > 1) {
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedSectionHeaderHeight = 25;
    } else {
        self.tableView.sectionHeaderHeight = 0;
    }
    
    
    
    NSMutableArray *tokens = [NSMutableArray arrayWithCapacity:tickets.count];
    int i = 0;
    __weak typeof(self) weakSelf = self;
    for (RLMResults *results in tickets) {
        tokens[i] = [results addNotificationBlock:^(RLMResults *results, RLMCollectionChange *changes, NSError *error) {
            
            //Basically we have an issue where notifs for some section are received first.
            //Solving this requires either on a UI level using multiple table views for building a massive new notification system
            //But I don't have a whole lot of time so I'm going to be lazy.
                
            //Next year's organizers: FIX THIS.
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
            
        }];
        i++;
    }
    self.notificationTokens = [NSArray arrayWithArray:tokens];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark MEHMentorTicketTableViewCellDelegate

- (void)handleAction:(MEHMentorAction)action forTicketWithServerID:(NSString *)serverID {
    if (![[MEHUserStoreController sharedUserStoreController]isUserLoggedIn]) {
        
        self.pendingAction = action;
        self.pendingActionTicket = serverID;
        UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController *loginVC = [MEHLoginViewController loginViewControllerInNavigationControllerWithDelegate:self];
        [rootVC presentViewController:loginVC animated:YES completion:nil];
        
        
        return;
    }
    self.pendingActionTicket = nil;
    self.pendingAction = 0;
    
    SCLAlertView *alertView = [[SCLAlertView alloc]initWithNewWindow];
    
    NSString *verb = [MEHMentorshipStoreController verbForAction:action];
    
    //this should be a category.
    if([verb hasSuffix:@"e"]) {
        verb = [[[verb substringWithRange:NSMakeRange(0, verb.length-1)]stringByAppendingString:@"ing"]capitalizedString];
    } else {
        verb= [[verb stringByAppendingString:@"ing"]capitalizedString];
    }
    
    [alertView showWaiting:verb subTitle:nil closeButtonTitle:nil duration:0];
    
    [[[MEHMentorshipStoreController sharedMentorshipStoreController]performAction:action onTicketWithIdentifier:serverID]continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [alertView hideView];
            
        });
        return nil;
    }];
}

#pragma mark MEHLoginViewControllerDelegate


- (void)didLoginSuccessfully:(MEHLoginViewController *)loginVC {
    if(loginVC.presentingViewController) {
        [loginVC.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
       [self removeContentViewController:self.loginVC];
    }
    self.loginVC = nil;
    
    [self refresh];
}

- (void)didDismissLoginScreen:(MEHLoginViewController *)loginVC {
    self.pendingActionTicket = nil;
    self.pendingAction = 0;
}

@end
