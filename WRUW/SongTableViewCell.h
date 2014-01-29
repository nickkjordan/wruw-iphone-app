//
//  SongTableViewCell.h
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import <Social/Social.h>

@interface SongTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UILabel *albumLabel;
@property (nonatomic, weak) IBOutlet UILabel *labelLabel;
@property (weak, nonatomic) IBOutlet UILabel *byLabel;
@property (weak, nonatomic) IBOutlet UIButton *thumbnailImageView;

@property (weak, nonatomic) IBOutlet UIView *socialView;
- (IBAction)favoritePush:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
- (IBAction)composeFBPost:(id)sender;
- (IBAction)composeTwitterPost:(id)sender;
- (IBAction)searchSong:(id)sender;
- (IBAction)imageTapped:(id)sender;

-(id)initWithViewController:(UIViewController*)c;
-(void)postSocial:(SLComposeViewController *)social;
- (void)configureForSong:(Song *)song controlView:(UIViewController *)c;
@property (weak) UITableViewController *ctrl;
@property (weak) Song *currentSong;

@end
