#import "ShowCell.h"

@implementation ShowCell

- (void)configureForShow:(Show *)show {
    self.showTextLabel.text = show.title;
    self.hostTextLabel.text = [show.hosts componentsJoinedByString:@", "];
    self.timeTextLabel.text = show.time;
}

@end
