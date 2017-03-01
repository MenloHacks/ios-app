//
//  UIColor+ColorPalette.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "UIColor+ColorPalette.h"

@implementation UIColor(ColorPalette)

+ (instancetype)menloHacksPurple {
  return [self colorWithRed:125.f   / 255.0f
                      green:91.0f / 255.0f
                       blue:166.0f / 255.0f
                      alpha:1.f];
}

+ (instancetype)menloHacksGray {
  return [self colorWithRed:89.f   / 255.0f
                      green:89.0f / 255.0f
                       blue:89.0f / 255.0f
                      alpha:1.f];
}

@end
