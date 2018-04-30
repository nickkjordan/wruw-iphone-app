//
//  DisplayViewController.h
//  WRUW
//
//  Created by Nick Jordan on 11/15/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "PlaylistsTableViewController.h"
#import <EventKitUI/EventKitUI.h>

@interface DisplayViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playlistsButton;

// Show info
@property (weak, nonatomic) IBOutlet UILabel *currentShowTitle;
@property (weak, nonatomic) IBOutlet UILabel *currentShowHost;
@property (weak, nonatomic) IBOutlet UITextView *currentShowInfo;
@property (weak, nonatomic) IBOutlet UILabel *currentShowTime;
@property (weak, nonatomic) IBOutlet UILabel *showGenre;

@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

- (IBAction)favoritePush:(id)sender;

@property (strong, nonatomic) Show *currentShow;

@end
