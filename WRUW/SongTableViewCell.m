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

@synthesize nameLabel, artistLabel, albumLabel, labelLabel, byLabel, thumbnailImageView, socialView, favButton,ctrl;

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
    
    if([[UIImage imageNamed:@"heart_24.png"] isEqual:favButton.currentImage]){
    
        UIImage *toImage = [UIImage imageNamed:@"heart_24_red.png"];
        [UIView animateWithDuration:0.5 animations:^{
            favButton.alpha = 0.0f;
        } completion:^(BOOL finished) {
            favButton.imageView.animationImages = [NSArray arrayWithObjects:toImage,nil];
            [favButton.imageView startAnimating];
            [UIView animateWithDuration:0.5 animations:^{
                favButton.alpha = 1.0f;
            }];
        }];
    }else if ([[UIImage imageNamed:@"heart_24_red.png"] isEqual:favButton.currentImage]) {
        UIImage *toImage = [UIImage imageNamed:@"heart_24.png"];
        [UIView animateWithDuration:0.5 animations:^{
            favButton.alpha = 0.0f;
        } completion:^(BOOL finished) {
            favButton.imageView.animationImages = [NSArray arrayWithObjects:toImage,nil];
            [favButton.imageView startAnimating];
            [UIView animateWithDuration:0.5 animations:^{
                favButton.alpha = 1.0f;
            }];
        }];
    }
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
    UIImage *albumArt = thumbnailImageView.imageView.image;
    
    [social setInitialText:[NSString stringWithFormat:@"Listening to \"%@\" by %@ on WRUW!",song,artist]];
    [social addURL:[NSURL URLWithString:@"wruw.org"]];
    [social addImage:albumArt];
    [ctrl presentViewController:social animated:YES completion:nil];
}

- (IBAction)searchSong:(id)sender {
    
    NSString *artist = [artistLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *title = [nameLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/search?q=%@+%@", title, artist]]];
}

- (IBAction)imageTapped:(id)sender {
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
    [self.thumbnailImageView setImage:song.image forState:UIControlStateNormal];
    self.currentSong = song;
    self.ctrl = c;
}

@end
