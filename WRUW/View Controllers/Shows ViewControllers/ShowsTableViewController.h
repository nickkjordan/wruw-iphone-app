//
//  ShowsTableViewController.h
//  WRUW
//
//  Created by Nick Jordan on 11/15/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayViewController.h"
#import "ShowCell.h"
#import "ArrayDataSource.h"
#import <CoreData/CoreData.h>

@interface ShowsTableViewController : UITableViewController <UISearchResultsUpdating, UISearchBarDelegate,UITableViewDataSource>

@property (atomic) int dayOfWeek;
@property (strong, nonatomic) UISearchController *searchController;

@end
