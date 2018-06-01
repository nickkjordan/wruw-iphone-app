#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SongTableViewCell.h"
#import "ArrayDataSource.h"
#import "MarqueeLabel.h"
#import "WRUWModule-Swift.h"

@interface HomeViewController : UIViewController <UINavigationBarDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet MarqueeLabel *showTitle;
@property (weak, nonatomic) IBOutlet UITextView *showDescription;
@property (weak, nonatomic) IBOutlet PlaylistTableView *tableView;
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
