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
 
    [ctrl.tableView reloadData];
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
        UIImage *albumArt = thumbnailImageView.imageView.image;
        
        [facebookPost setInitialText:[NSString stringWithFormat:@"Listening to \"%@\" by %@ on WRUW!",song,artist]];
        [facebookPost addURL:[NSURL URLWithString:@"wruw.org"]];
        [facebookPost addImage:albumArt];
        [ctrl presentViewController:facebookPost animated:YES completion:nil];
    
}

- (IBAction)composeTwitterPost:(id)sender {
    
        SLComposeViewController *twitterPost = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        NSString *artist = artistLabel.text;
        NSString *song = nameLabel.text;
        UIImage *albumArt = thumbnailImageView.imageView.image;
        
        [twitterPost setInitialText:[NSString stringWithFormat:@"Listening to \"%@\" by %@ on WRUW!",song,artist]];
        [twitterPost addURL:[NSURL URLWithString:@"wruw.org"]];
        [twitterPost addImage:albumArt];
        [ctrl presentViewController:twitterPost animated:YES completion:nil];

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

@end
