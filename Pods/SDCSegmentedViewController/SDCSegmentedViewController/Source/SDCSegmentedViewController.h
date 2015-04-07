//
//  SDCSegmentedViewController.h
//  SDCSegmentedViewController
//
//  Created by Scott Berrevoets on 3/15/13.
//  Copyright (c) 2013 Scotty Doesn't Code. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef NS_ENUM
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#endif

typedef NS_ENUM(NSInteger, SDCSegmentedViewControllerControlPosition) {
	SDCSegmentedViewControllerControlPositionNavigationBar,
	SDCSegmentedViewControllerControlPositionToolbar
};

@class SDCSegmentedViewController;

@protocol SDCSegmentedViewControllerDelegate <NSObject>
@optional

/**
 *  Sent when the segmented controller switched the view controller it's displaying
 */
- (void)segmentedViewController:(SDCSegmentedViewController *)sender didTransitionToViewController:(UIViewController *)newController;

@end

@interface SDCSegmentedViewController : UIViewController
@property (nonatomic, readonly, strong) UISegmentedControl *segmentedControl;
@property (nonatomic) SDCSegmentedViewControllerControlPosition position; // Defaults to navigation bar

@property (nonatomic, weak) id <SDCSegmentedViewControllerDelegate> delegate;

/*
 *  When set to YES, swiping the view will switch view controllers (like Notification Center in iOS 7+)
 */
@property (nonatomic) BOOL switchesWithSwipe;
@property (nonatomic, readonly) UISwipeGestureRecognizer *leftSwipeRecognizer;
@property (nonatomic, readonly) UISwipeGestureRecognizer *rightSwipeRecognizer;

@property (nonatomic) NSUInteger segmentedControlWidth;

// NSArray of UIViewController subclasses
- (instancetype)initWithViewControllers:(NSArray *)viewControllers;

// Takes segmented control item titles separately from the view controllers
- (instancetype)initWithViewControllers:(NSArray *)viewControllers titles:(NSArray *)titles;

// Add a new view controller as the last segment
- (void)addViewController:(UIViewController *)viewController;
- (void)addViewController:(UIViewController *)viewController withTitle:(NSString *)title;

// Add segments from storyboard. The strings in the array should match segue identifiers in the storyboard.
- (void)addStoryboardSegments:(NSArray *)segments;

@end