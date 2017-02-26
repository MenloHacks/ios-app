//
//  SingleMapViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 1/3/16.
//  Copyright © 2016 MenloHacks. All rights reserved.
//

#import "SingleMapViewController.h"

#import "AutolayoutHelper.h"
#import "UIImageView+AFNetworking.h"
#import "UIFontDescriptor+AvenirNext.h"


#import "MEHLocation.h"

@interface SingleMapViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) MEHLocation *map;


@end

@implementation SingleMapViewController


- (void)viewDidLoad {
  [super viewDidLoad];
  _imageView = [[UIImageView alloc]init];
  _imageView.contentMode = UIViewContentModeScaleAspectFit;
  _captionLabel = [[UILabel alloc]init];
  _captionLabel.font = [UIFont fontWithDescriptor:[UIFontDescriptor preferredAvenirNextFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]size:0];
  _captionLabel.textAlignment = NSTextAlignmentCenter;
  _captionLabel.textColor = [UIColor blackColor];
  UIScrollView *scrollView = [[UIScrollView alloc]init];
  scrollView.delegate = self;
  scrollView.maximumZoomScale = 3.0;
  scrollView.minimumZoomScale = 1.0;
  
  UIView *parent = [UIView new];
  
  [AutolayoutHelper configureView:parent subViews:VarBindings(scrollView, _captionLabel)
                      constraints:@[@"H:|-[scrollView]-|",
                                    @"H:|-[_captionLabel]-|",
                                    @"V:|-42-[_captionLabel]-12-[scrollView]|"]];
  [AutolayoutHelper configureView:scrollView subViews:NSDictionaryOfVariableBindings(_imageView)
                                              constraints:@[@"H:|[_imageView]|",
                                                            @"X:_imageView.centerY == superview.centerY"]];
  
  [AutolayoutHelper configureView:self.view fillWithSubView:parent];
  
  NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:_imageView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                     toItem:scrollView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     multiplier:1
                                                                      constant:0];
  
  NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:_imageView
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationLessThanOrEqual
                                                                        toItem:scrollView
                                                                     attribute:NSLayoutAttributeHeight
                                                                    multiplier:1
                                                                      constant:0];
  
  [self.view addConstraint:widthConstraint];
  [self.view addConstraint:heightConstraint];
  
  
  if (_map) {
    [self configureFromMap:_map];
  }
}

-(void)configureFromMap:(MEHLocation *)map {
  if(_imageView) {
      _captionLabel.text = map.locationName;
      [_imageView setImageWithURL:[NSURL URLWithString:map.mapURL]];
  }
  _map = map;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}



@end
