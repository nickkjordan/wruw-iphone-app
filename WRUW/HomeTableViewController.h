//
//  HomeTableViewController.h
//  WRUW
//
//  Created by Nick Jordan on 1/31/14.
//  Copyright (c) 2014 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TFHpple.h"
#import "Song.h"
#include "Playlist.h"
#import "SongTableViewCell.h"
#import "ArrayDataSource.h"

@interface HomeTableViewController : UITableViewController

- (IBAction)streamPlay:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *showTitle;
@property (weak, nonatomic) IBOutlet UITextView *showDescription;

@property (weak, nonatomic) IBOutlet UIView *infoView;

@end
