//
//  InfoTableViewCell.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MEHEvent, MEHAnnouncement;

@interface InfoTableViewCell : UITableViewCell

- (void)configureWithEvent : (MEHEvent *)event;
- (void)configureWithAnnouncement:(MEHAnnouncement *)announcement;

@end
