//
//  FavoritesTableViewController.m
//  WRUW
//
//  Created by Nick Jordan on 11/22/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import <Social/Social.h>
#import "EmptyFavoritesView.h"
#import <sys/utsname.h>

@interface FavoritesTableViewController ()
{
    NSMutableArray *_favorites;
    NSNotificationCenter *center;
}
@property (nonatomic, strong) ArrayDataSource *songsArrayDataSource;
@property (nonatomic, strong) UIView *emptyView;

@end

@implementation FavoritesTableViewController

@synthesize tableView;

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.tableView.delegate = self;
    }

    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self loadFavs];
    [self checkIfEmpty];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadFavs];

    UINib *cellNib = [UINib nibWithNibName:@"SongTableViewCell" bundle:nil];
    
    [self.tableView registerNib:cellNib
         forCellReuseIdentifier:@"SongTableCellType"];
    
    //Creates notification for cleared song
    center = [NSNotificationCenter defaultCenter];
}

-(void)viewDidAppear:(BOOL)animated{
    [center addObserver:self
               selector:@selector(deleteUnfavorited:)
                   name:@"notification"
                 object:nil];
}

-(void)checkIfEmpty:(float)time {
    if (!_favorites.count) {
        _emptyView = [EmptyFavoritesView emptySongs];

        UILayoutGuide *layoutMarginsGuide = self.view.layoutMarginsGuide;

        [_emptyView setAlpha:0.0];
        [self.view addSubview:_emptyView];

        [_emptyView.leftAnchor constraintEqualToAnchor:layoutMarginsGuide.leftAnchor];
        [_emptyView.topAnchor constraintEqualToAnchor:layoutMarginsGuide.topAnchor];
        [_emptyView.bottomAnchor constraintEqualToAnchor:layoutMarginsGuide.bottomAnchor];
        [_emptyView.rightAnchor constraintEqualToAnchor:layoutMarginsGuide.rightAnchor];

        [UIView animateWithDuration:time
                         animations:^{_emptyView.alpha = 1.0;
                         }];
    } else if ([_emptyView isDescendantOfView:self.view]) {
        [_emptyView removeFromSuperview];
    }
}

-(void)checkIfEmpty {
    [self checkIfEmpty:0.0];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [center removeObserver:self name:@"notification" object:nil];
}

-(NSString *) getFilePath {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[pathArray objectAtIndex:0] stringByAppendingPathComponent:@"favorites.plist"];
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
    
    NSArray *cells = [self.tableView visibleCells];
    
    for (SongTableViewCell *cell in cells) {
        [cell buttonAnimation:cell.favButton withImage:@"heart_24_red.png"];
    }
}

+ (void)deletePList {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"favorites.plist"];
    
    NSError *error;
    if(![[NSFileManager defaultManager] removeItemAtPath:path error:&error])
    {
        //TODO: Handle/Log error
    }
}

-(void)deleteUnfavorited:(NSNotification *)notification {
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:[[notification userInfo] objectForKey:@"cell"]];

    NSArray *indexPaths = [NSArray arrayWithObject:clickedButtonPath];
    
    [_favorites removeObjectAtIndex:clickedButtonPath.row];
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    [self checkIfEmpty:0.5];
}

#pragma mark - Table view data source

- (void)setupTableView {
    TableViewCellConfigureBlock configureCell =
        ^(SongTableViewCell *cell, Song *song) {
            [cell configureForSong:song];
        };

    self.songsArrayDataSource =
        [[ArrayDataSource alloc] initWithItems:_favorites
                                cellIdentifier:@"SongTableViewCell"
                            configureCellBlock:configureCell];

    self.tableView.dataSource = self.songsArrayDataSource;
    [self.tableView registerNib:[UINib nibWithNibName:@"SongTableViewCell" bundle:nil ]
         forCellReuseIdentifier:@"SongTableViewCell"];

    [self.tableView reloadData];
    
}

- (NSIndexPath *)tableView:(UITableView *)tableViewIn
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SongTableViewCell *cell =
        (SongTableViewCell *)[tableViewIn cellForRowAtIndexPath:indexPath];
    
    if ([cell isSelected]) {
        // Deselect manually.
        [tableViewIn deselectRowAtIndexPath:indexPath animated:YES];
        
        return nil;
    }
    
    return indexPath;
}

@end
