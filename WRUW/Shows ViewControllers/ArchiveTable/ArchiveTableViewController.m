#import "ArchiveTableViewController.h"
#import "SongTableViewCell.h"
#import <Social/Social.h>
#import "WRUWModule-Swift.h"

@interface ArchiveTableViewController ()
{
    Playlist *_archive;
    UIActivityIndicatorView *spinner;
}
@property (nonatomic, strong) ArrayDataSource *songsArrayDataSource;

@end

@implementation ArchiveTableViewController

@synthesize currentPlaylist, currentShowTitle;

-(void)loadSongs {
    GetPlaylist *playlistService =
        [[GetPlaylist alloc] initWithShowName:currentPlaylist.showName.asQuery
                                         date:currentPlaylist.dateString];

    [playlistService request:^(WruwResult *result) {
        if (result.success) {
            _archive = result.success;

            __block BOOL setup;

            dispatch_async(dispatch_get_main_queue(), ^{
                setup = [self setupTableView];
                [spinner stopAnimating];
            });

            int i = 0;
//            for (Playlist *playlist in _archive) {
//                [song loadImage:^void () {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//                        NSArray *indexArray = [NSArray arrayWithObjects:indexPath, nil];
//                        [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
//                    });
//                }];
//                
//                i++;
//            }
        }
    }];
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
    
    [self setTitle:currentPlaylist.dateString];
    [self setupTableView];
    
    spinner = [[UIActivityIndicatorView alloc] init];
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    spinner.color = [[ThemeManager current] wruwMainOrangeColor];
    [self.view addSubview:spinner];
    
    [spinner startAnimating];
    
    [self loadSongs];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SongTableViewCell"
                                               bundle:nil ]
         forCellReuseIdentifier:@"SongTableViewCell"];

}

#pragma mark - Table view delegate

- (BOOL)setupTableView
{
    TableViewCellConfigureBlock configureCell = ^(SongTableViewCell *cell, Song *song) {
        [cell configureForSong:song controlView:self];
    };
    self.songsArrayDataSource =
        [[ArrayDataSource alloc] initWithItems:_archive.songs.mutableCopy
                                cellIdentifier:@"SongTableViewCell"
                            configureCellBlock:configureCell];

    self.tableView.dataSource = self.songsArrayDataSource;
    [self.tableView registerNib:[UINib nibWithNibName:@"SongTableViewCell" bundle:nil ] forCellReuseIdentifier:@"SongTableViewCell"];
    [self.tableView reloadData];
    
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongTableViewCell *cell = (SongTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isSelected]) {
        // Deselect manually.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        return nil;
    }
    
    return indexPath;
}


@end
