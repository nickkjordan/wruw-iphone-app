//
//  ArchiveTableViewController.h
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
#import "Song.h"
#import "ArrayDataSource.h"

@interface ArchiveTableViewController : UITableViewController

@property (nonatomic, strong) Playlist *currentPlaylist;

@property (nonatomic, strong) NSString *currentShowTitle;



@end
