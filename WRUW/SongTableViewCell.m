//
//  SongTableViewCell.m
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "SongTableViewCell.h"

@interface SongTableViewCell(){
}
@end

@implementation SongTableViewCell

@synthesize nameLabel, artistLabel, albumLabel, labelLabel, byLabel, thumbnailImageView, socialView, favButton, ctrl, facebookButton, twitterButton;

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
                              artistLabel.alpha = 0;
                              albumLabel.alpha = 0;
                              labelLabel.alpha = 0;
                              byLabel.alpha = 0;
                              socialView.alpha = 1;
                          }];
    } else {
        [UILabel animateWithDuration:0.5
                          animations:^{
                              nameLabel.alpha = 1;
                              artistLabel.alpha = 1;
                              albumLabel.alpha = 1;
                              labelLabel.alpha = 1;
                              byLabel.alpha = 1;
                             socialView.alpha = 0;
                         }];
    }
}

-(NSString *) getFilePath {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[pathArray objectAtIndex:0] stringByAppendingPathComponent:@"favorites.plist"];
}

-(void) saveFavorite:(Song *)currentSong {
    
    NSString *path = [self getFilePath];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (fileExists) {
        NSData *favoritesData = [[NSData alloc] initWithContentsOfFile:path];
        // Get current content.
        NSMutableArray *content = [NSKeyedUnarchiver unarchiveObjectWithData:favoritesData];
        // Make a mutable copy.
//        NSMutableArray *newContent = [oldContent mutableCopy];
        
        if ([content containsObject:currentSong]) {
            
            [content removeObject:currentSong];
            
            NSDictionary *dataDict2=[NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:self]
                                                                forKeys:[NSArray arrayWithObject:@"cell"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"notification"
                                                                object:self
                                                              userInfo:dataDict2];
        } else {
            // Add new stuff.
            [content insertObject:currentSong atIndex:0];
        }
        
        // Now, write the plist:
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:content];
        
        [data writeToFile:path atomically:YES];
    } else {
        NSMutableArray *newFavorite = [[NSMutableArray alloc] initWithObjects:currentSong, nil];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newFavorite];
        
        [data writeToFile:path atomically:YES];
    }
 
}

- (IBAction)favoritePush:(id)sender {

    [self saveFavorite:_currentSong];
    
    UIImage *testHeart  = [UIImage imageNamed:@"heart_24.png"];
    UIImage *currentHeart = favButton.currentImage;
    
    NSString *switchHeart = ([testHeart isEqual:currentHeart]) ? (@"heart_24_red.png") : (@"heart_24.png");
    
    [self buttonAnimation:favButton withImage:switchHeart];
}

- (IBAction)composeFBPost:(id)sender {
    
    SLComposeViewController *facebookPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
    [self postSocial:facebookPost];
    
}

- (IBAction)composeTwitterPost:(id)sender {
    
    SLComposeViewController *twitterPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
    [self postSocial:twitterPost];

}

-(void)postSocial:(SLComposeViewController *)social{
    NSString *artist = artistLabel.text;
    NSString *song = nameLabel.text;
    UIImage *albumArt = thumbnailImageView.image;
    
    if (social.serviceType == SLServiceTypeFacebook){
        [self buttonAnimation:facebookButton withImage:@"facebook_blue.png"];
    } else if (social.serviceType == SLServiceTypeTwitter){
        [self buttonAnimation:twitterButton withImage:@"twitter_blue.png"];
    }
    
    [social setInitialText:[NSString stringWithFormat:@"Listening to \"%@\" by %@ on WRUW!",song,artist]];
    [social addURL:[NSURL URLWithString:@"wruw.org"]];
    [social addImage:albumArt];
    [ctrl presentViewController:social animated:YES completion:nil];
}

-(void)buttonAnimation:(UIButton *)button withImage:(NSString *)imageName {
    
    UIImage *toImage = [UIImage imageNamed:imageName];
    
    [UIView transitionWithView:self.socialView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        button.imageView.animationImages = [NSArray arrayWithObjects:toImage,nil];
                        [button.imageView startAnimating];
                        [button setImage:toImage forState:UIControlStateNormal];
                    } completion:nil];
    
}

- (IBAction)searchSong:(id)sender {
    
    NSString *artist = [artistLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *title = [nameLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/search?q=%@+%@", title, artist]]];
}

-(id)initWithViewController:(UITableViewController*)c {
    
    if (self = [super init]) {
        ctrl = c;
    }
    return self;
}

- (void)configureForSong:(Song *)song controlView:(UIViewController *)c
{
    self.nameLabel.text = song.songName;
    self.albumLabel.text = song.album;
    self.artistLabel.text = song.artist;
    self.labelLabel.text = song.label;
    self.thumbnailImageView.image =  song.image;
    self.currentSong = song;
    self.ctrl = c;
}

@end
