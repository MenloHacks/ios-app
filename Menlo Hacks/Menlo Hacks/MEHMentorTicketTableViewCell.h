//
//  MEHMentorTicketTableViewCell.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MEHMentorshipStoreController.h"

@class MEHMentorTicket;

@protocol MEHMentorTicketTableViewCellDelegate <NSObject>

@required
- (void)handleAction : (MEHMentorAction)action forTicketWithServerID : (NSString *)serverID;

@end

@interface MEHMentorTicketTableViewCell : UITableViewCell

@property (nonatomic) MEHMentorTicket *ticket;
@property (nonatomic, weak) id<MEHMentorTicketTableViewCellDelegate>delegate;

@end
