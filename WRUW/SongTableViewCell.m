//
//  SongTableViewCell.m
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "SongTableViewCell.h"
#import <Social/Social.h>

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
                         }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              artistLabel.alpha = 0;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              albumLabel.alpha = 0;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              labelLabel.alpha = 0;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              byLabel.alpha = 0;
                          }];
        [UIView animateWithDuration:0.5
                          animations:^{
                              socialView.alpha = 1;
                          }];
    } else {
        [UILabel animateWithDuration:0.5
                          animations:^{
                              nameLabel.alpha = 1;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              artistLabel.alpha = 1;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              albumLabel.alpha = 1;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              labelLabel.alpha = 1;
                          }];
        [UILabel animateWithDuration:0.5
                          animations:^{
                              byLabel.alpha = 1;
                          }];
        [UIView animateWithDuration:0.5
                         animations:^{
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
        
        BOOL why = [content containsObject:currentSong];
        
        if (!why) {
            // Add new stuff.
            [content insertObject:currentSong atIndex:0];
        } else {
            [content removeObjectIdenticalTo:currentSong];
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
    [UIView animateWithDuration:0.5 animations:^{
        favButton.backgroundColor = [UIColor redColor];
    }];
}

- (IBAction)composeFBPost:(id)sender {
    
        SLComposeViewController *facebookPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        NSString *artist = artistLabel.text;
        NSString *song = nameLabel.text;
        UIImage *albumArt = thumbnailImageView.image;
        
        [facebookPost setInitialText:[NSString stringWithFormat:@"Listening to \"%@\" by %@ on WRUW!",song,artist]];
        [facebookPost addURL:[NSURL URLWithString:@"wruw.org"]];
        [facebookPost addImage:albumArt];
        [ctrl presentViewController:facebookPost animated:YES completion:nil];
    
}

- (IBAction)composeTwitterPost:(id)sender {
    
        SLComposeViewController *twitterPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        NSString *artist = artistLabel.text;
        NSString *song = nameLabel.text;
        UIImage *albumArt = thumbnailImageView.image;
        
        [twitterPost setInitialText:[NSString stringWithFormat:@"Listening to \"%@\" by %@ on WRUW!",song,artist]];
        [twitterPost addURL:[NSURL URLWithString:@"wruw.org"]];
        [twitterPost addImage:albumArt];
        [ctrl presentViewController:twitterPost animated:YES completion:nil];

}

-(id)initWithViewController:(UITableViewController*)c {
    
    if (self = [super init]) {
        ctrl = c;
    }
    return self;
}

@end
