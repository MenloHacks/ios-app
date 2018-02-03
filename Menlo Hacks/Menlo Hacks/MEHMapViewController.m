//
//  MapViewController.m
//  Menlo Hacks
//
//  Created by Jason Scharff on 12/31/15.
//  Copyright © 2015 MenloHacks. All rights reserved.
//

#import "MEHMapViewController.h"

#import "AutolayoutHelper.h"
#import <Bolts/Bolts.h>
#import "UIColor+ColorPalette.h"

#import "MEHMapStoreController.h"
#import "MEHLocation.h"
#import "SingleMapViewController.h"
#import "RLMRealm+MenloHacks.h"

#define DEFAULT_OFFSET ((CGFloat) 20)

@interface MEHMapViewController()<UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) RLMResults<MEHLocation *> *maps;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) SingleMapViewController *singleMapVC;

@end

@implementation MEHMapViewController

-(void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  _loadingView.color = [UIColor menloHacksPurple];
  [AutolayoutHelper configureView:self.view subViews:VarBindings(_loadingView)
                      constraints: @[@"X:_loadingView.centerX == superview.centerX",
                                     @"X:_loadingView.centerY == superview.centerY"]];
  [_loadingView startAnimating];

  [self setupView];
    
  self.parentViewController.navigationItem.rightBarButtonItems = @[];
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.parentViewController.navigationItem.rightBarButtonItems = @[];
}

- (void)setupView {
    
    [[[MEHMapStoreController sharedMapStoreController]fetchMaps]continueWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        _maps= [[MEHMapStoreController sharedMapStoreController]maps];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_maps.count > 1){
                [self configurePageView];
            }
            else if (_maps.count == 1){
                [self configureSingleMap];
            }
        });
        return nil;
    }];
    
}


-(void)configureSingleMap {
  _singleMapVC = [self viewControllerAtIndex:0];
  [self addChildViewController:_singleMapVC];
  [AutolayoutHelper configureView:self.view fillWithSubView:_singleMapVC.view];
  [_singleMapVC didMoveToParentViewController:self];
  [_loadingView stopAnimating];
  _loadingView.hidden = YES;
}

-(void)configurePageView {
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor blackColor];
    pageControl.currentPageIndicatorTintColor = [UIColor menloHacksPurple];
  
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.view.frame = self.view.frame;
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    NSArray *viewControllers = [NSArray arrayWithObject:[self viewControllerAtIndex:0]];
    [_pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [_pageViewController didMoveToParentViewController:self];
    [_loadingView stopAnimating];
    _loadingView.hidden = YES;
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

- (SingleMapViewController *)viewControllerAtIndex: (NSUInteger)index {
  SingleMapViewController *vc = [[SingleMapViewController alloc]init];
  vc.index = index;
  [vc configureFromMap:_maps[index]];
  return vc;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
  // The number of items reflected in the page indicator.
  return _maps.count;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
  return 0;
}


@end
