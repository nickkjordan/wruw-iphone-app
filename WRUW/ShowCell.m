//
//  ShowCell.m
//  WRUW
//
//  Created by Nick Jordan on 1/31/14.
//  Copyright (c) 2014 Nick Jordan. All rights reserved.
//

#import "ShowCell.h"

@implementation ShowCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForShow:(Show *)show
{
    self.textLabel.text = show.title;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", show.host, show.time];
}

@end
