//
//  ShowCell.m
//  WRUW
//
//  Created by Nick Jordan on 1/31/14.
//  Copyright (c) 2014 Nick Jordan. All rights reserved.
//

#import "ShowCell.h"

@implementation ShowCell

- (void)configureForShow:(Show *)show
{
    self.showTextLabel.text = show.title;
    self.hostTextLabel.text = show.host;
    self.timeTextLabel.text = show.time;
}

@end
