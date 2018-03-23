#import "ShowCell.h"

@implementation ShowCell

- (void)configureForShow:(Show *)show {
    self.showTextLabel.text = show.title;
    self.hostTextLabel.text = show.hostsDisplay;
    self.timeTextLabel.text = show.startTime;
}

@end
