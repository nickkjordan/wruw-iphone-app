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

- (IBAction)switchContainerView:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            if (self.currentVC == self.favShowsVC) {
                [self addChildViewController:self.favSongsVC];
                self.favSongsVC.view.frame = self.containerView.bounds;
                [self moveToNewController:self.favSongsVC];
            }
            break;
        case 1:
            if (self.currentVC == self.favSongsVC) {
                [self addChildViewController:self.favShowsVC];
                self.favShowsVC.view.frame = self.containerView.bounds;
                [self moveToNewController:self.favShowsVC];
            }
            break;
        default:
            break;
    }
}

-(void)moveToNewController:(UIViewController *) newController {
    [self.currentVC willMoveToParentViewController:nil];
    [self transitionFromViewController:self.currentVC toViewController:newController duration:.6 options:UIViewAnimationOptionTransitionFlipFromLeft animations:nil
                            completion:^(BOOL finished) {
                                [self.currentVC removeFromParentViewController];
                                [newController didMoveToParentViewController:self];
                                self.currentVC = newController;
                            }];
}

@end

