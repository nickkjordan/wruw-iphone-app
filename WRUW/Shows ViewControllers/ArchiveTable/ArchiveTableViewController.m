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

            for (Song *song in _archive.songs) {
                if (song.album.length == 0 && song.artist.length == 0) {
                    continue;
                }

                GetReleases *releasesService = 
                    [[GetReleases alloc] initWithRelease:song.album
                                                  artist:song.artist];

                [releasesService request:^(WruwResult *result) {
                    Release *release = [(NSArray *)result.success firstObject];
                    if (release.id.length == 0) {
                        return;
                    }

                    GetCoverArt *coverArtService =
                        [[GetCoverArt alloc] initWithReleaseId:release.id];

                    [coverArtService request:^(WruwResult *result) {
                        if (!result.success) {
                            return;
                        }
                        
                        song.image = result.success;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                            NSArray *indexArray = [NSArray arrayWithObjects:indexPath, nil];
                            [self.tableView reloadRowsAtIndexPaths:indexArray
                                                  withRowAnimation:UITableViewRowAnimationNone];
                        });
                    }];
                }];
                
                i++;
            }
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:currentPlaylist.dateString];
    [self setupTableView];
    
    spinner = [[UIActivityIndicatorView alloc] init];
    spinner.center =
        CGPointMake(self.view.frame.size.width / 2.0,
                    self.view.frame.size.height / 2.0);
    
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

- (BOOL)setupTableView {
    TableViewCellConfigureBlock configureCell =
        ^(SongTableViewCell *cell, Song *song) {
            [cell configureForSong:song controlView:self];
        };

    self.songsArrayDataSource =
        [[ArrayDataSource alloc] initWithItems:_archive.songs.mutableCopy
                                cellIdentifier:@"SongTableViewCell"
                            configureCellBlock:configureCell];

    self.tableView.dataSource = self.songsArrayDataSource;
    [self.tableView registerNib:[UINib nibWithNibName:@"SongTableViewCell"
                                               bundle:nil ]
         forCellReuseIdentifier:@"SongTableViewCell"];
    [self.tableView reloadData];
    
    return YES;
}

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SongTableViewCell *cell =
        (SongTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];

    if ([cell isSelected]) {
        // Deselect manually.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        return nil;
    }
    
    return indexPath;
}


@end
