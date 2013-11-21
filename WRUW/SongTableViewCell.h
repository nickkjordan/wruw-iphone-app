//
//  SongTableViewCell.h
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UILabel *albumLabel;
@property (nonatomic, weak) IBOutlet UILabel *labelLabel;
@property (nonatomic, weak) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIView *socialView;

@end
