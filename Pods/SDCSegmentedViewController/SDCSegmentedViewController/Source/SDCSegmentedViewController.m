//
//  SDCSegmentedViewController.m
//  SDCSegmentedViewController
//
//  Created by Scott Berrevoets on 3/15/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import "SDCSegmentedViewController.h"
#import "UIViewController+MSLayoutSupport.h"

@interface SDCSegmentedViewController ()
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic) NSInteger currentSelectedIndex;

@property (nonatomic, strong) NSString *segueNames;

@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeRecognizer;
@end

@implementation SDCSegmentedViewController

- (NSMutableArray *)viewControllers {
	if (!_viewControllers)
		_viewControllers = [NSMutableArray array];
    return _viewControllers;
}

- (NSMutableArray *)titles {
	if (!_titles)
		_titles = [NSMutableArray array];
    return _titles;
}

- (void)setPosition:(SDCSegmentedViewControllerControlPosition)position {
	_position = position;
	[self moveControlToPosition:position];
}

- (void)setSwitchesWithSwipe:(BOOL)switchesWithSwipe {
    if (_switchesWithSwipe != switchesWithSwipe) {
        if (switchesWithSwipe) {
            self.leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchViewControllerWithSwipe:)];
            self.leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            
            self.rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(switchViewControllerWithSwipe:)];
            self.rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
            
            [self.view addGestureRecognizer:self.leftSwipeRecognizer];
            [self.view addGestureRecognizer:self.rightSwipeRecognizer];
        } else {
            [self.view removeGestureRecognizer:self.leftSwipeRecognizer];
            [self.view removeGestureRecognizer:self.rightSwipeRecognizer];
        }
    }
}

#pragma mark - Initializers

- (instancetype)initWithViewControllers:(NSArray *)viewControllers {
	return [self initWithViewControllers:viewControllers titles:[viewControllers valueForKeyPath:@"@unionOfObjects.title"]];
}

- (instancetype)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles {
	self = [super init];
	
	if (self) {
		[self createSegmentedControl];
		
		_currentSelectedIndex = UISegmentedControlNoSegment;
		_viewControllers = [NSMutableArray array];
		_titles = [NSMutableArray array];
		
		[viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
			if ([obj isKindOfClass:[UIViewController class]] && index < [titles count])
				[self addViewController:obj withTitle:titles[index]];
		}];
		
		if ([_viewControllers count] == 0 || [_viewControllers count] != [_titles count]) {
			self = nil;
			NSLog(@"%@: Invalid configuration of view controllers and titles.", NSStringFromClass([self class]));
		}
	}
	
	return self;
}

- (void)createSegmentedControl {
	_segmentedControl = [[UISegmentedControl alloc] initWithItems:nil];
	[_segmentedControl addTarget:self action:@selector(changeViewController:) forControlEvents:UIControlEventValueChanged];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
	_segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
#endif
}

- (void)awakeFromNib {
	[self createSegmentedControl];
	_currentSelectedIndex = UISegmentedControlNoSegment;

	if ([self.segueNames length] > 0) {
		NSArray *segueNames = [self.segueNames componentsSeparatedByString:@","];
		[self addStoryboardSegments:segueNames];
	}
}

#pragma mark - View Controller Lifecycle

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	if ([self.viewControllers count] == 0)
		[NSException raise:@"SDCSegmentedViewControllerException" format:@"SDCSegmentedViewController has no view controllers that it can display."];
	
	if (self.currentSelectedIndex == UISegmentedControlNoSegment)
		[self showFirstViewController];
	else if (self.currentSelectedIndex < [self.viewControllers count])
		[self observeViewController:self.viewControllers[self.currentSelectedIndex]];
	
	[self moveControlToPosition:self.position];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIViewController *childViewController = self.viewControllers[self.currentSelectedIndex];
    [self adjustScrollViewInsets:childViewController];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self stopObservingViewController:self.viewControllers[self.currentSelectedIndex]];
}

#pragma mark - View Management

- (void) adjustScrollViewInsets:(UIViewController *)viewController {

	if ([viewController.view isKindOfClass:[UIScrollView class]] && viewController.automaticallyAdjustsScrollViewInsets) {
        UIScrollView *scrollView = (UIScrollView *)viewController.view;
        UIEdgeInsets insets = UIEdgeInsetsMake(self.ms_navigationBarTopLayoutGuide.length,
                                               0.0,
                                               self.ms_navigationBarBottomLayoutGuide.length,
                                               0.0);
        scrollView.contentInset = insets;
        scrollView.scrollIndicatorInsets = insets;
    }
}

- (void)moveControlToPosition:(SDCSegmentedViewControllerControlPosition)newPosition {
	switch (newPosition) {
		case SDCSegmentedViewControllerControlPositionNavigationBar:
			self.navigationItem.titleView = self.segmentedControl;
			break;
		case SDCSegmentedViewControllerControlPositionToolbar: {
			UIBarButtonItem *flexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
			UIBarButtonItem *control = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
			
			self.toolbarItems = @[flexible, control, flexible];
			break;
		}
	}
	
	if ([self.viewControllers count] > 0 && self.currentSelectedIndex != UISegmentedControlNoSegment)
		[self updateBarsForViewController:self.viewControllers[self.segmentedControl.selectedSegmentIndex]];
}

- (void)updateBarsForViewController:(UIViewController *)viewController {
	if (self.position == SDCSegmentedViewControllerControlPositionToolbar)
		self.title = viewController.title;
	else if (self.position == SDCSegmentedViewControllerControlPositionNavigationBar)
		self.toolbarItems = viewController.toolbarItems;

	self.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems;
	self.navigationItem.leftBarButtonItems = viewController.navigationItem.leftBarButtonItems;
}

#pragma mark - View Controller Containment

- (void)addStoryboardSegments:(NSArray *)segments {
	[segments enumerateObjectsUsingBlock:^(NSString *segment, NSUInteger idx, BOOL *stop) {
		[self performSegueWithIdentifier:segment sender:self];
	}];
}

- (void)addViewController:(UIViewController *)viewController {
	if (viewController && viewController.title)
		[self addViewController:viewController withTitle:viewController.title];
	else
		NSLog(@"%@: Can't add view controller (%@) because no title was specified!", NSStringFromClass([self class]), viewController);
}

- (void)addViewController:(UIViewController *)viewController withTitle:(NSString *)title {
	[self.viewControllers addObject:viewController];
	[self.titles addObject:title];
	[self addChildViewController:viewController];
	
	[self.segmentedControl insertSegmentWithTitle:title atIndex:[self.titles indexOfObject:title] animated:YES];
	[self resizeSegmentedControl];
}

#pragma mark - View Controller Transitioning

- (void)showFirstViewController {
	UIViewController *firstViewController = [self.viewControllers firstObject];
	[self.view addSubview:firstViewController.view];
	
	[self willTransitionToViewController:firstViewController];
	[self didTransitionToViewController:firstViewController];
}

- (void)switchViewControllerWithSwipe:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        if (self.currentSelectedIndex < [self.viewControllers count] - 1)
            [self transitionToViewControllerWithIndex:self.currentSelectedIndex + 1];
    } else {
        if (self.currentSelectedIndex > 0)
            [self transitionToViewControllerWithIndex:self.currentSelectedIndex - 1];
    }
}

- (void)willTransitionToViewController:(UIViewController *)viewController {
	if (self.currentSelectedIndex != UISegmentedControlNoSegment) {
		UIViewController *oldViewController = self.viewControllers[self.currentSelectedIndex];
		[oldViewController willMoveToParentViewController:nil];
		[self stopObservingViewController:oldViewController];
	}
	
	viewController.view.frame = self.view.bounds;
    if ([[viewController.view.subviews firstObject] isKindOfClass:[UITableView class]]) {
        [[viewController.view.subviews firstObject] setFrame:viewController.view.frame];
    }
	[self adjustScrollViewInsets:viewController];
}

- (void)didTransitionToViewController:(UIViewController *)viewController {
	[viewController didMoveToParentViewController:self];
	[self updateBarsForViewController:viewController];
	[self observeViewController:viewController];
	
	self.segmentedControl.selectedSegmentIndex = [self.viewControllers indexOfObject:viewController];
	self.currentSelectedIndex = [self.viewControllers indexOfObject:viewController];
    
    if ([self.delegate respondsToSelector:@selector(segmentedViewController:didTransitionToViewController:)])
        [self.delegate segmentedViewController:self didTransitionToViewController:viewController];
}

- (void)transitionToViewControllerWithIndex:(NSUInteger)index {
    UIViewController *oldViewController = self.viewControllers[self.currentSelectedIndex];
	UIViewController *newViewController = self.viewControllers[index];
	
	[self willTransitionToViewController:newViewController];
	[self transitionFromViewController:oldViewController
					  toViewController:newViewController
							  duration:0
							   options:UIViewAnimationOptionTransitionNone
							animations:nil
							completion:^(BOOL finished) {
								[self didTransitionToViewController:newViewController];
							}];
}

- (void)changeViewController:(UISegmentedControl *)segmentedControl {
	[self transitionToViewControllerWithIndex:segmentedControl.selectedSegmentIndex];
}

#pragma mark - KVO

- (void)observeViewController:(UIViewController *)viewController {
	[viewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
	[viewController addObserver:self forKeyPath:@"toolbarItems" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)stopObservingViewController:(UIViewController *)viewController {
	[viewController removeObserver:self forKeyPath:@"title"];
	[viewController removeObserver:self forKeyPath:@"toolbarItems"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	[self updateBarsForViewController:object];
}

#pragma mark - Segmented Control Width

- (void)resizeSegmentedControl {
	if (self.segmentedControlWidth == 0) {
		[self.segmentedControl sizeToFit];
		return;
	}
	
	for (int x = 0; x < self.segmentedControl.numberOfSegments; x++) {
		[self.segmentedControl setWidth:self.segmentedControlWidth / self.segmentedControl.numberOfSegments
					  forSegmentAtIndex:x];
	}
}

- (void)setSegmentedControlWidth:(NSUInteger)segmentedControlWidth {
	_segmentedControlWidth = segmentedControlWidth;
	[self resizeSegmentedControl];
}

@end
