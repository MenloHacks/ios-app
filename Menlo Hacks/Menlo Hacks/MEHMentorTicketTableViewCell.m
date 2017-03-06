//
//  MEHMentorTicketTableViewCell.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHMentorTicketTableViewCell.h"

#import "AutolayoutHelper.h"

#import "NSDate+Utilities.h"
#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"

#import "MEHMentorTicket.h"

@interface MEHMentorTicketTableViewCell()

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *contactLabel;

@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, strong) UIView *mainContentView;



@end

@implementation MEHMentorTicketTableViewCell


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    _mainContentView = [UIView new];
    _mainContentView.backgroundColor = [UIColor whiteColor];
    
    self.timeLabel = [UILabel new];
    self.timeLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleBody]size:0];
    self.timeLabel.textColor = [UIColor menloHacksPurple];
    
    
    
    UIFont *mainFont = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
    
    self.descriptionLabel = [UILabel new];
    self.descriptionLabel.font = mainFont;
    self.descriptionLabel.textColor = [UIColor menloHacksGray];
    self.descriptionLabel.numberOfLines = 0;
    
    
    self.contactLabel = [UILabel new];
    self.contactLabel.font = mainFont;
    self.contactLabel.textColor = [UIColor menloHacksGray];
    self.contactLabel.numberOfLines = 0;
    
    self.locationLabel = [UILabel new];
    self.locationLabel.font = mainFont;
    self.locationLabel.textColor = [UIColor menloHacksGray];
    self.locationLabel.numberOfLines = 0;
    
    self.actionButton = [UIButton new];
    [self.actionButton setBackgroundColor:[UIColor menloHacksPurple]];
    self.actionButton.titleLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [AutolayoutHelper configureView:self.contentView
                           subViews:NSDictionaryOfVariableBindings(_mainContentView)
                        constraints:@[@"H:|[_mainContentView]|",
                                      @"V:|[_mainContentView]-20-|"]];
    
    [AutolayoutHelper configureView:self.mainContentView
                           subViews:NSDictionaryOfVariableBindings(_timeLabel, _descriptionLabel, _contactLabel, _locationLabel, _actionButton)
                        constraints:@[@"H:[_timeLabel]-12-|",
                                      @"H:|-[_descriptionLabel]-|",
                                      @"H:|-[_locationLabel]-|",
                                      @"H:|-[_contactLabel]-|",
                                      @"H:|-[_actionButton]-|",
                                      @"V:|-12-[_timeLabel]-[_descriptionLabel]-[_locationLabel]-[_contactLabel]-20-[_actionButton]-|"]];
    
    
    
}

- (void)setTicket:(MEHMentorTicket *)ticket {
    _ticket = ticket;
    self.locationLabel.text = ticket.ticketLocation;
    self.descriptionLabel.text = ticket.ticketDescription;
    self.contactLabel.text = ticket.contact;
    self.timeLabel.text = [NSDate formattedShortTimeFromDate:ticket.timeCreated];
    
    NSString *action;
    
    if(ticket.claimed == NO) {
        if(ticket.expired == NO) {
            action = @"claim";
        } else {
            action = @"Reopen";
        }
    }
    else {
        if(ticket.expired == NO) {
            action = @"Reopen";
        } else {
            action = @"Close";
        }
    }
    
    [self.actionButton setTitle:action forState:UIControlStateNormal];
}

@end
