#import "ArchiveViewController.h"
#import "SongTableViewCell.h"
#import <Social/Social.h>
#import "WRUWModule-Swift.h"

@interface ArchiveViewController ()
{
    Playlist *_archive;
    UIActivityIndicatorView *spinner;
}

@end

@implementation ArchiveViewController

@synthesize currentPlaylist, currentShowTitle, tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:currentPlaylist.dateString];

    spinner = [[UIActivityIndicatorView alloc] init];
    spinner.center =
        CGPointMake(self.view.frame.size.width / 2.0,
                    self.view.frame.size.height / 2.0);
    
    [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    spinner.color = [[ThemeManager current] wruwMainOrangeColor];
    [self.view addSubview:spinner];

    [spinner startAnimating];
    
    [tableView loadWithShow:currentPlaylist.showName.asQuery
                       date:currentPlaylist.dateString];
}

@end
