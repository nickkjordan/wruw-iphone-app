//
//  SongTableViewCell.m
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "SongTableViewCell.h"

@implementation SongTableViewCell

@synthesize nameLabel, artistLabel, albumLabel, labelLabel, thumbnailImageView, socialView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    socialView.hidden = !socialView.hidden;
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        [UILabel animateWithDuration:0.5
                         animations:^{
                             nameLabel.alpha = 0;
                         }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              artistLabel.alpha = 0;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              albumLabel.alpha = 0;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              labelLabel.alpha = 0;
                          }];
        [UIView animateWithDuration:0.5
                          animations:^{
                              socialView.alpha = 1;
                          }];
    } else {
        [UILabel animateWithDuration:0.5
                          animations:^{
                              nameLabel.alpha = 1;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              artistLabel.alpha = 1;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              albumLabel.alpha = 1;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              labelLabel.alpha = 1;
                          }];
        [UIView animateWithDuration:0.5
                         animations:^{
                             socialView.alpha = 0;
                         }];
    }
}

@end
