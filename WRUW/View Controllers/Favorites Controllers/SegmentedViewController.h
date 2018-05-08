//
//  SegmentedViewController.h
//  WRUW
//
//  Created by Nick Jordan on 12/12/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentedViewController : UIViewController <UINavigationBarDelegate>

- (IBAction)switchContainerView:(id)sender;

@property (strong, nonatomic) UITableViewController *favSongsVC;
@property (strong, nonatomic) UITableViewController *favShowsVC;
@property (strong, nonatomic) UIViewController *currentVC;

@end
