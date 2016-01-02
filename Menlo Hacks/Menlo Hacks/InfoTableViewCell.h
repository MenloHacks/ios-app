//
//  InfoTableViewCell.h
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event, Announcement;

@interface InfoTableViewCell : UITableViewCell

- (void)configureWithEvent : (Event *)event;
- (void)configureWithAnnouncement : (Announcement *)announcement;

@end