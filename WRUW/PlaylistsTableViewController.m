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

-(void)loadPlaylist {
    
    // 3
    NSString *showsXpathQueryString = @"//*[@id='playlist-select']/option[position()>1]";
    NSArray *showsNodes = [currentParser searchWithXPathQuery:showsXpathQueryString];
    
    // 4
    NSMutableArray *newPlaylists = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 1; i < [showsNodes count]; i++) {
        TFHppleElement *element = [showsNodes objectAtIndex:i];
        
        // 5
        Playlist *playlist = [[Playlist alloc] init];
        [newPlaylists addObject:playlist];
        
        playlist.date = [[element firstChild] content];
        playlist.idValue = [element objectForKey:@"value"];
    }
    
    // 8
    _playlists = newPlaylists;
    [self.tableView reloadData];
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
    
    [self loadPlaylist];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
