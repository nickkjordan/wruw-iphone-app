//
//  HomeViewController.h
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

@interface HomeViewController : UIViewController <UINavigationBarDelegate, UITableViewDelegate>

- (IBAction)streamPlay:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *showTitle;
@property (weak, nonatomic) IBOutlet UITextView *showDescription;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIView *showContainer;
@property (weak, nonatomic) IBOutlet UILabel *hostLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showDescriptionHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showViewHeight;

@property (weak, nonatomic) IBOutlet UIView *infoView;

@property (nonatomic,strong) AVPlayer *player;

@end
