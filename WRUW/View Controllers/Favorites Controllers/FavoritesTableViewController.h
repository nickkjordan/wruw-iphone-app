#import <UIKit/UIKit.h>
#import "ArrayDataSource.h"
#import "SongTableViewCell.h"
#import "WRUWModule-Swift.h"

@interface FavoritesTableViewController : UIViewController <UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (id) initWithStyle:(UITableViewStyle)style;
-(void)deleteUnfavorited:(NSNotification *)notification;

@end
