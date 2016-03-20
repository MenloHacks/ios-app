//
//  SingleMapViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/3/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "SingleMapViewController.h"

#import "AutolayoutHelper.h"
#import "UIFontDescriptor+AvenirNext.h"
#import <ParseUI/ParseUI.h>

#import "Map.h"

@interface SingleMapViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) PFImageView *imageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) Map *map;


@end

@implementation SingleMapViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  _imageView = [[PFImageView alloc]init];
  _imageView.contentMode = UIViewContentModeScaleAspectFit;
  _captionLabel = [[UILabel alloc]init];
  _captionLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
  _captionLabel.textAlignment = NSTextAlignmentCenter;
  _captionLabel.textColor = [UIColor blackColor];
  UIScrollView *scrollView = [[UIScrollView alloc]init];
  scrollView.delegate = self;
  scrollView.maximumZoomScale = 3.0;
  scrollView.minimumZoomScale = 1.0;
  scrollView.scrollEnabled = NO;
  
  UIView *parent = [UIView new];
  
  [AutolayoutHelper configureView:parent subViews:VarBindings(scrollView, _captionLabel)
                      constraints:@[@"H:|-[scrollView]-|",
                                    @"H:|-[_captionLabel]-|",
                                    @"V:|-42-[_captionLabel]-12-[scrollView]|"]];
  [AutolayoutHelper configureView:scrollView subViews:NSDictionaryOfVariableBindings(_imageView)
                                              constraints:@[@"H:|[_imageView]|",
                                                            @"X:_imageView.centerY == superview.centerY"]];
  
  [AutolayoutHelper configureView:self.view fillWithSubView:parent];
  
  NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
  [self.view addConstraint:constraint];
   
  
  
  if (_map) {
    [self configureFromMap:_map];
  }
}

-(void)configureFromMap:(Map *)map {
  if(_imageView) {
    _imageView.file = map.image;
    _captionLabel.text = map.caption;
    [_imageView loadInBackground];
  }
  _map = map;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return _imageView;
}



@end
