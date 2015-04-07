//
//  FavoriteShowsTableViewController.m
//  WRUW
//
//  Created by Nick Jordan on 12/13/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "FavoriteShowsTableViewController.h"
#import "EmptyFavoritesView.h"

@interface FavoriteShowsTableViewController ()
{
    NSMutableArray *_favorites;
}
@property (nonatomic, strong) ArrayDataSource *showsArrayDataSource;
@property (nonatomic, strong) UIView *emptyView;

@end

@implementation FavoriteShowsTableViewController

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showDisplaySegue"]) {
        DisplayViewController *dvc = [segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        
        Show *c = [_favorites objectAtIndex:path.row];
        
        [dvc setCurrentShow:c];
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadFavs];

    [self.tableView registerNib:[UINib nibWithNibName:@"ShowCell" bundle:nil ] forCellReuseIdentifier:@"ShowCell"];

}

-(void)checkIfEmpty:(float)time {
    if (!_favorites.count) {
        _emptyView = [EmptyFavoritesView emptyShows];
        _emptyView.frame = self.view.frame;
        _emptyView.bounds = self.view.bounds;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_emptyView setAlpha:0.0];
        [self.view addSubview:_emptyView];
        [UIView animateWithDuration:time
                         animations:^{_emptyView.alpha = 1.0;
                         }];
    } else if ([_emptyView isDescendantOfView:self.view]) {
        [_emptyView removeFromSuperview];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
}

-(void)checkIfEmpty {
    [self checkIfEmpty:0.0];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self loadFavs];
    
    [self checkIfEmpty];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *) getFilePath {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[pathArray objectAtIndex:0] stringByAppendingPathComponent:@"favoriteShows.plist"];
}

-(void)loadFavs {
    NSString *myPath = [self getFilePath];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:myPath];
    
    if (fileExists) {
        NSData *favoritesData = [[NSData alloc] initWithContentsOfFile:myPath];
        // Get current content.
        
        _favorites = [NSKeyedUnarchiver unarchiveObjectWithData:favoritesData];
    }
    
    [self setupTableView];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showDisplaySegue" sender:self];
}

#pragma mark - Table view data source

- (void)setupTableView
{
    TableViewCellConfigureBlock configureCell = ^(ShowCell *cell, Show *show) {
        [cell configureForShow:show];
    };
    self.showsArrayDataSource = [[ArrayDataSource alloc] initWithItems:_favorites
                                                        cellIdentifier:@"ShowCell"
                                                    configureCellBlock:configureCell];
    self.tableView.dataSource = self.showsArrayDataSource;
    [self.tableView reloadData];
}

@end
