@class PlaylistInfo;

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "Song.h"
#import "ArrayDataSource.h"
#import "WRUWModule-Swift.h"

@interface ArchiveViewController : UIViewController

@property (nonatomic, strong) PlaylistInfo *currentPlaylist;

@property (nonatomic, strong) NSString *currentShowTitle;

@property (strong, nonatomic) IBOutlet PlaylistTableView *tableView;

@end
