//
//  InfoTableViewCell.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "InfoTableViewCell.h"

#import "AutolayoutHelper.h"
#import "UIFontDescriptor+AvenirNext.h"
#import "UIColor+ColorPalette.h"
#import "NSDate+Utilities.h"

#import "MEHEvent.h"
#import "MEHLocation.h"
#import "MEHAnnouncement.h"

@interface InfoTableViewCell()

@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *locationLabel;

@end

@implementation InfoTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  [self commonInit];
  return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  [self commonInit];
  return self;
}

-(id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  [self commonInit];
  return self;
}

-(void)commonInit {
  UIFont *font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleBody]size:0];
  _descriptionLabel = [UILabel new];
  _descriptionLabel.font = font;
  _descriptionLabel.numberOfLines = 0;
  _descriptionLabel.textColor = [UIColor menloHacksPurple];
  
  _timeLabel = [UILabel new];
  _timeLabel.font = font;
  _timeLabel.textColor = [UIColor menloGold];
  
  _locationLabel = [UILabel new];
  _locationLabel.font = font;
  _locationLabel.textColor = [UIColor lightGrayColor];
  _locationLabel.textAlignment = NSTextAlignmentRight;
  
  [AutolayoutHelper configureView:self subViews:VarBindings(_locationLabel, _timeLabel, _descriptionLabel)
                      constraints:@[@"H:[_locationLabel]-|",
                                    @"H:|-[_descriptionLabel]-|",
                                    @"H:|-[_timeLabel]",
                                    @"V:|-[_timeLabel]-[_descriptionLabel]-|",
                                    @"V:|-[_locationLabel]"]];
  
}

-(void)configureWithEvent : (MEHEvent *)event{
    _descriptionLabel.text = event.shortDescription;
    _locationLabel.text = event.location.locationName;
    _timeLabel.text = [NSDate formattedShortTimeFromDate:event.startTime];
}

-(void)configureWithAnnouncement:(MEHAnnouncement *)announcement {
    _descriptionLabel.text = announcement.message;
    _timeLabel.text = [NSDate formattedShortTimeFromDate:announcement.time];
    _locationLabel.text = @"";
}

@end
