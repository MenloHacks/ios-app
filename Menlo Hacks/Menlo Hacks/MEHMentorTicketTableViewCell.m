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
#import "MEHMentorActionButton.h"
#import "TTTAttributedLabel.h"

@interface MEHMentorTicketTableViewCell() <TTTAttributedLabelDelegate>

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) TTTAttributedLabel *contactLabel;

@property (nonatomic, strong) MEHMentorActionButton *primaryActionButton;
@property (nonatomic, strong) MEHMentorActionButton *secondaryActionButton;

@property (nonatomic, strong) UIView *mainContentView;

@property (nonatomic, strong) NSLayoutConstraint *secondaryActionButtonZeroHeight;
@property (nonatomic) BOOL containsTwoButtons;



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
    
    
    self.contactLabel = [TTTAttributedLabel new];
    self.contactLabel.font = mainFont;
    self.contactLabel.enabledTextCheckingTypes = NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink;
    self.contactLabel.textColor = [UIColor menloHacksGray];
    self.contactLabel.numberOfLines = 0;
    self.contactLabel.delegate = self;
    
    self.locationLabel = [UILabel new];
    self.locationLabel.font = mainFont;
    self.locationLabel.textColor = [UIColor menloHacksGray];
    self.locationLabel.numberOfLines = 0;
    
    self.primaryActionButton = [[MEHMentorActionButton alloc]init];
    [self.primaryActionButton addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchDown];
    
    self.secondaryActionButton = [[MEHMentorActionButton alloc]init];
    [self.secondaryActionButton addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchDown];
    
    
    self.secondaryActionButtonZeroHeight = [NSLayoutConstraint constraintWithItem:self.secondaryActionButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:0];
    
    
    [AutolayoutHelper configureView:self.contentView
                           subViews:NSDictionaryOfVariableBindings(_mainContentView)
                        constraints:@[@"H:|[_mainContentView]|",
                                      @"V:|[_mainContentView]-20-|"]];
    
    [AutolayoutHelper configureView:self.mainContentView
                           subViews:NSDictionaryOfVariableBindings(_timeLabel, _descriptionLabel, _contactLabel, _locationLabel, _primaryActionButton, _secondaryActionButton)
                        constraints:@[@"H:[_timeLabel]-12-|",
                                      @"H:|-[_descriptionLabel]-|",
                                      @"H:|-[_locationLabel]-|",
                                      @"H:|-[_contactLabel]-|",
                                      @"H:|-[_primaryActionButton]-|",
                                      @"H:|-[_secondaryActionButton]-|",
                                      @"V:|-12-[_timeLabel]-[_descriptionLabel]-[_locationLabel]-[_contactLabel]-20-[_primaryActionButton]-[_secondaryActionButton]-|"]];
    
    
    
}

- (void)setTicket:(MEHMentorTicket *)ticket {
    if(self.ticket && !self.containsTwoButtons) {
        [self.mainContentView removeConstraint:self.secondaryActionButtonZeroHeight];
    }
    
    _ticket = ticket;
    self.locationLabel.text = ticket.ticketLocation;
    self.descriptionLabel.text = ticket.ticketDescription;
    self.contactLabel.text = ticket.contact;
    self.timeLabel.text = [NSDate formattedShortTimeFromDate:ticket.timeCreated];
    
    self.primaryActionButton.action = ticket.primaryAction;
    
   
    if(ticket.secondaryAction != MEHMentorActionNone) {
        self.secondaryActionButton.action = ticket.secondaryAction;
    } else {
        [self.mainContentView addConstraint:self.secondaryActionButtonZeroHeight];
        self.containsTwoButtons = NO;
    }
    

}

- (void)handleAction : (MEHMentorActionButton *)button {
    if(self.delegate) {
        [self.delegate handleAction:button.action forTicketWithServerID:self.ticket.serverID];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]] options:@{} completionHandler:nil];
}

@end
