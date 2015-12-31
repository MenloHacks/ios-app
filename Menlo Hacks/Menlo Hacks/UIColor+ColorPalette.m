//
//  UIColor+ColorPalette.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/30/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "UIColor+ColorPalette.h"

@implementation UIColor(ColorPalette)

+ (instancetype)menloBlue {
  return [self colorWithRed:11.f   / 255.0f
                      green:61.0f / 255.0f
                       blue:145.0f / 255.0f
                      alpha:1.f];
}

+ (instancetype)menloGold {
  return [self colorWithRed:254.f   / 255.0f
                      green:166.0f / 255.0f
                       blue:32.0f / 255.0f
                      alpha:1.f];
}

@end
