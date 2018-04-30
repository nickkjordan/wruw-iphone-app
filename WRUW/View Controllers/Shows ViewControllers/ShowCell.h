#import <UIKit/UIKit.h>

@class Show;

@interface ShowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *showTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTextLabel;

- (void)configureForShow:(Show *)show;

@end
