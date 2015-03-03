//
//  ShowCell.h
//  WRUW
//
//  Created by Nick Jordan on 1/31/14.
//  Copyright (c) 2014 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"

@interface ShowCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *showTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeTextLabel;

- (void)configureForShow:(Show *)show;

@end
