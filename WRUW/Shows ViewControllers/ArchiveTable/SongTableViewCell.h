//
//  SongTableViewCell.h
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@class Song;

@interface SongTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIView *view;

@property (weak, nonatomic) IBOutlet UIView *socialView;
- (IBAction)favoritePush:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
- (IBAction)composeFBPost:(id)sender;
- (IBAction)composeTwitterPost:(id)sender;
- (IBAction)searchSong:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

-(id)initWithViewController:(UIViewController*)c;
-(void)postSocial:(SLComposeViewController *)social;
- (void)configureForSong:(Song *)song controlView:(UIView *)c;
-(void)buttonAnimation:(UIButton *)button withImage:(NSString *)imageName;

@property (weak) UITableViewController *ctrl;
@property (weak) Song *currentSong;

@end
