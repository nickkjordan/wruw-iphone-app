#import "ShowCell.h"
#import "WRUWModule-Swift.h"

@implementation ShowCell

- (void)configureForShow:(Show *)show {
    self.showTextLabel.text = show.title;
    self.hostTextLabel.text = show.hostsDisplay;
    self.timeTextLabel.text = [show.startTime displayTime];
}

@end
