//
//  HomeViewController.h
//  WRUW
//
//  Created by Nick Jordan on 9/10/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntrinsicTableView.h"

@interface HomeViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
- (IBAction)streamPlay:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *showTitle;
@property (weak, nonatomic) IBOutlet UITextView *showDescription;

@property (weak, nonatomic) IBOutlet IntrinsicTableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@end
