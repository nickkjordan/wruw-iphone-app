#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Song.h"
#include "Playlist.h"
#import "SongTableViewCell.h"
#import "ArrayDataSource.h"
#import "MarqueeLabel.h"

@interface HomeViewController : UIViewController <UINavigationBarDelegate, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet MarqueeLabel *showTitle;
@property (weak, nonatomic) IBOutlet UITextView *showDescription;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIView *showContainer;
@property (weak, nonatomic) IBOutlet MarqueeLabel *hostLabel;
@property (weak, nonatomic) IBOutlet UIView *showView;
@property (weak, nonatomic) IBOutlet UIButton *moreInfoButton;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showDescriptionHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showViewHeight;

@property (weak, nonatomic) IBOutlet UIView *infoView;

@end
