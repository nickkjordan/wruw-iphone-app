#import "PlaylistsTableViewController.h"
#import "WRUWModule-Swift.h"

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
        
        PlaylistInfo *p = [_playlists objectAtIndex:path.row];
        
        [atvc setCurrentPlaylist:p];
        
        [atvc setCurrentShowTitle:currentShow.title];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _playlists = [currentShow.playlists mutableCopy];
}

#pragma mark - Table view data source

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
    
    PlaylistInfo *thisPlaylist = [_playlists objectAtIndex:indexPath.row];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, yyyy"];
    
    [[cell textLabel] setText:[formatter stringFromDate:thisPlaylist.date]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showArchiveSegue" sender:self];
}

@end
