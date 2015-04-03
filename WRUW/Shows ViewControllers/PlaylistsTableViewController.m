//
//  PlaylistsTableViewController.m
//  WRUW
//
//  Created by Nick Jordan on 11/18/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "PlaylistsTableViewController.h"

@interface PlaylistsTableViewController (){
    NSMutableArray *_playlists;
}

@end

@implementation PlaylistsTableViewController

@synthesize currentShow, currentParser;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showArchiveSegue"]) {
        ArchiveTableViewController *atvc = [segue destinationViewController];
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        
        Playlist *p = [_playlists objectAtIndex:path.row];
        
        [atvc setCurrentPlaylist:p];
        
        [atvc setCurrentShowTitle:currentShow.title];
    }
}

-(void)loadPlaylist
{
    [currentShow loadInfo:^{
        _playlists = [NSMutableArray arrayWithArray:currentShow.playlists];
        [self.tableView reloadData];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadPlaylist];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _playlists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Playlist *thisPlaylist = [_playlists objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSDate *myDate = [dateFormatter dateFromString:thisPlaylist.date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, yyyy"];
    
    [[cell textLabel] setText:[formatter stringFromDate:myDate]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showArchiveSegue" sender:self];
}

@end
