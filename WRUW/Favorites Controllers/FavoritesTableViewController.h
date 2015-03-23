//
//  FavoritesTableViewController.h
//  WRUW
//
//  Created by Nick Jordan on 11/22/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrayDataSource.h"
#import "SongTableViewCell.h"
#import "Song.h"

@interface FavoritesTableViewController : UIViewController <UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (id) initWithStyle:(UITableViewStyle)style;
-(void)deleteUnfavorited:(NSNotification *)notification;

@end
