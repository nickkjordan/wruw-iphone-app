//
//  PlaylistsTableViewController.h
//  WRUW
//
//  Created by Nick Jordan on 11/18/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "TFHpple.h"
#import "Show.h"

@interface PlaylistsTableViewController : UITableViewController

@property (nonatomic, strong) Show *currentShow;
@property (nonatomic, strong) TFHpple *currentParser;

@end
