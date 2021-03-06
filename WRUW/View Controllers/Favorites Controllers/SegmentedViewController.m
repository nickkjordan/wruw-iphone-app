//
//  SegmentedViewController.m
//  WRUW
//
//  Created by Nick Jordan on 12/12/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "SegmentedViewController.h"

@interface SegmentedViewController ()

@end

@implementation SegmentedViewController

@synthesize currentVC, favShowsVC, favSongsVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view layoutIfNeeded];
    
    self.favSongsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoriteSongs"];
    self.favShowsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoriteShows"];
    self.currentVC = self.favSongsVC;
    [self addChildViewController:favSongsVC];
    [self addContainerViewConstraints:self.currentVC];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.view setNeedsLayout];
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

- (IBAction)switchContainerView:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            if (self.currentVC == self.favShowsVC) {
                [self addChildViewController:self.favSongsVC];
                self.favSongsVC.view.frame = self.view.bounds;
                [self moveToNewController:self.favSongsVC direction:0];
            }
            break;
        case 1:
            if (self.currentVC == self.favSongsVC) {
                [self addChildViewController:self.favShowsVC];
                self.favShowsVC.view.frame = self.view.bounds;
                [self moveToNewController:self.favShowsVC direction:1];
            }
            break;
        default:
            break;
    }
}

-(void)moveToNewController:(UIViewController *) newController
                 direction:(int) param{
    [self.currentVC willMoveToParentViewController:nil];
    [self addChildViewController:newController];
    
    void (^completion)(BOOL) = ^(BOOL finished){
        [self.currentVC removeFromParentViewController];
        [newController didMoveToParentViewController:self];
        self.currentVC = newController;
        
        [self addContainerViewConstraints:self.currentVC];
    };
    
    // direction param:
    // 1 = right to left (Shows displayed)
    // 0 = left to right (Songs displayed)
    UIViewAnimationOptions options = param ?
        UIViewAnimationOptionTransitionFlipFromRight :
        UIViewAnimationOptionTransitionFlipFromLeft;
    
    [self transitionFromViewController:self.currentVC
                      toViewController:newController
                              duration:.6
                               options:options
                            animations:nil
                            completion:completion];
}

- (void)addContainerViewConstraints:(UIViewController *)viewController {
    UIView *subview = viewController.view;
    
    [self.view addSubview:subview];

    subview.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addConstraints:@[
        [NSLayoutConstraint constraintWithItem:subview
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1.0
                                      constant:0],

        [NSLayoutConstraint constraintWithItem:subview
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1.0
                                      constant:0],

        [NSLayoutConstraint constraintWithItem:subview
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1.0
                                      constant:0],

        [NSLayoutConstraint constraintWithItem:subview
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1
                                      constant:0],
                                ]
     ];
}

@end

