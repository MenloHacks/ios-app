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

#import "UIColor+ColorPalette.h"

#import "MEHMentorTicket.h"
#import "MEHMentorshipStoreController.h"
#import "MEHMentorTicketTableViewCell.h"

@interface MEHMentorshipViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) NSArray<RLMResults<MEHMentorTicket *> *>*tickets;
@property (nonatomic, strong) NSArray <RLMNotificationToken *>*notificationTokens;

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
    
    
    _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _loadingView.color = [UIColor menloHacksPurple];
    [AutolayoutHelper configureView:self.view subViews:VarBindings(_loadingView)
                        constraints: @[@"X:_loadingView.centerX == superview.centerX",
                                       @"X:_loadingView.centerY == superview.centerY"]];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.tintColor = [UIColor menloHacksPurple];
    //[refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refresh];
    
    [self refresh];

}

- (void)refresh {
    _tableView.hidden = YES;
    [_loadingView startAnimating];
    
    [self.fetchFromServer()continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
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
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.categories.count];
    for (NSString *category in self.categories) {
        RLMResults *results = [[MEHMentorTicket objectsWhere:@"category == %@", category]sortedResultsUsingProperty:@"timeCreated" ascending:NO];
        [array addObject:results];
    }
    self.tickets = [NSArray arrayWithArray:array];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tickets.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tickets[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MEHMentorTicketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMEHMentorTicketReuseIdentifier];
    cell.ticket = self.tickets[indexPath.section][indexPath.row];
    return cell;
}


- (void)setTickets:(NSArray<RLMResults<MEHMentorTicket *> *> *)tickets {
    _tickets = tickets;
    NSMutableArray *tokens = [NSMutableArray arrayWithCapacity:tickets.count];
    int i = 0;
    __weak typeof(self) weakSelf = self;
    for (RLMResults *results in tickets) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
