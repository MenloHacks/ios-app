//
//  MEHMentorActionButton.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

#import "MEHMentorActionButton.h"

#import "UIColor+ColorPalette.h"
#import "UIFontDescriptor+AvenirNext.h"


@implementation MEHMentorActionButton

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

- (void)commonInit {
    [self setBackgroundColor:[UIColor menloHacksPurple]];
    self.titleLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleHeadline]size:0];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)setAction:(MEHMentorAction)action {
    _action = action;
    [self setTitle:[[MEHMentorshipStoreController verbForAction:action]capitalizedString] forState:UIControlStateNormal];
}

@end
