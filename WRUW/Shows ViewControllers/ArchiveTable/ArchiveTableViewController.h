@class PlaylistInfo;

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "Song.h"
#import "ArrayDataSource.h"

@interface ArchiveTableViewController : UITableViewController

@property (nonatomic, strong) PlaylistInfo *currentPlaylist;

@property (nonatomic, strong) NSString *currentShowTitle;



@end
