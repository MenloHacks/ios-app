//
//  MapViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/31/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "MapViewController.h"

#import "AutolayoutHelper.h"
#import <ParseUI/ParseUI.h>
#import "UIColor+ColorPalette.h"

#import "MapStoreController.h"
#import "SingleMapViewController.h"
#import "Map.h"

#define DEFAULT_OFFSET ((CGFloat) 20)

@interface MapViewController()<UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) NSArray<Map *> *maps;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSArray <SingleMapViewController *> *mapVCs;

@end

@implementation MapViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _loadingView.color = [UIColor menloBlue];
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_loadingView)
                      constraints: @[@"X:_loadingView.centerX == superview.centerX",
                                     @"X:_loadingView.centerY == superview.centerY"]];
  [_loadingView startAnimating];

  
  [[MapStoreController sharedMapStoreController]getMaps:^(NSArray<Map *> *results) {
    _maps = results;
    [self configurePageView];
  }];
  
  
  
}

-(void)configurePageView {
  UIPageControl *pageControl = [UIPageControl appearance];
  pageControl.pageIndicatorTintColor = [UIColor blackColor];
  pageControl.currentPageIndicatorTintColor = [UIColor menloBlue];
  
  _mapVCs = [self getMapVCs];
  _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
  self.pageViewController.view.frame = self.view.frame;
  _pageViewController.dataSource = self;
  _pageViewController.delegate = self;
  NSArray *viewControllers = [NSArray arrayWithObject:_mapVCs[0]];
  [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
  [self addChildViewController:_pageViewController];
  [self.view addSubview:_pageViewController.view];
  [_pageViewController didMoveToParentViewController:self];
  [_loadingView stopAnimating];
  _loadingView.hidden = YES;
}

-(NSArray *)getMapVCs {
  NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:_maps.count];
  for (Map *map in _maps) {
    SingleMapViewController *vc = [[SingleMapViewController alloc]init];
    [vc configureFromMap:map];
    [array addObject:vc];
  }
  return array;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
  
  NSUInteger index = ((SingleMapViewController *)viewController).index;
  
  if(index == 0) {
    return nil;
  } else {
    UIViewController *vc = [self viewControllerAtIndex:index - 1];
    return vc;
  }
  return nil;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
  
  NSUInteger index = ((SingleMapViewController *)viewController).index;
  
  if(index == _maps.count - 1) {
    return nil;
  } else {
    UIViewController *vc = [self viewControllerAtIndex:index+1];
    return vc;
  }
  return nil;
}

- (UIViewController *)viewControllerAtIndex: (NSUInteger)index {
  SingleMapViewController *vc = [[SingleMapViewController alloc]init];
  vc.index = index;
  [vc configureFromMap:_maps[index]];
  return vc;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
  // The number of items reflected in the page indicator.
  return _mapVCs.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
  return 0;
}


@end
