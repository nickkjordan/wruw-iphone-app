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
@synthesize containerView, favoritesItem;
@synthesize currentVC, favShowsVC, favSongsVC;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.favSongsVC = self.childViewControllers.lastObject;
    self.favShowsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoriteShows"];
    self.currentVC = self.favSongsVC;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (IBAction)switchContainerView:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            if (self.currentVC == self.favShowsVC) {
                [self addChildViewController:self.favSongsVC];
                self.favSongsVC.view.frame = self.containerView.bounds;
                [self moveToNewController:self.favSongsVC direction:0];
            }
            break;
        case 1:
            if (self.currentVC == self.favSongsVC) {
                [self addChildViewController:self.favShowsVC];
                self.favShowsVC.view.frame = self.containerView.bounds;
                [self moveToNewController:self.favShowsVC direction:1];
            }
            break;
        default:
            break;
    }
}

-(void)moveToNewController:(UIViewController *) newController direction:(int) param{
    // direction param:
    // 1 = right to left (Shows displayed)
    // 0 = left to right (Songs displayed)
    [self.currentVC willMoveToParentViewController:nil];
    
    if (param) {
        [self transitionFromViewController:self.currentVC toViewController:newController duration:.6
                                   options:UIViewAnimationOptionTransitionFlipFromRight
                                animations:nil
                                completion:^(BOOL finished) {
                                    [self.currentVC removeFromParentViewController];
                                    [newController didMoveToParentViewController:self];
                                    self.currentVC = newController;
                                }];
    } else {
        [self transitionFromViewController:self.currentVC toViewController:newController duration:.6
                                   options:UIViewAnimationOptionTransitionFlipFromLeft
                                animations:nil
                                completion:^(BOOL finished) {
                                    [self.currentVC removeFromParentViewController];
                                    [newController didMoveToParentViewController:self];
                                    self.currentVC = newController;
                                }];
    }
    
    
}

@end

