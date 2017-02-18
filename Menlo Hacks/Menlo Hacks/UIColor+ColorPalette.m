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

+ (instancetype)menloGold {
  return [self colorWithRed:254.f   / 255.0f
                      green:166.0f / 255.0f
                       blue:32.0f / 255.0f
                      alpha:1.f];
}

+ (instancetype)emeraldGreen {
  return [self colorWithRed:46.f/255.f
                      green:204.f/255.f
                       blue:133.f/255.f
                      alpha:1];
}

@end
