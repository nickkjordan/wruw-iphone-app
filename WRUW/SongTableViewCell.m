//
//  SongTableViewCell.m
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "SongTableViewCell.h"
#import "Song.h"

@implementation SongTableViewCell

@synthesize nameLabel, artistLabel, albumLabel, labelLabel, thumbnailImageView, socialView, favButton;

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
        NSMutableArray *oldContent = [NSKeyedUnarchiver unarchiveObjectWithData:favoritesData];
        // Make a mutable copy.
        NSMutableArray *newContent = [oldContent mutableCopy];
        // Add new stuff.
        [newContent insertObject:currentSong atIndex:0];
        // Now, write the plist:
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newContent];
        
        [data writeToFile:path atomically:YES];
    } else {
        NSMutableArray *newFavorite = [[NSMutableArray alloc] initWithObjects:currentSong, nil];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newFavorite];
        
        [data writeToFile:path atomically:YES];
    }
    
}

- (IBAction)favoritePush:(id)sender {
    Song *currentSong = [Song alloc];
    currentSong.artist = artistLabel.text;
    currentSong.album = albumLabel.text;
    currentSong.songName = nameLabel.text;
    currentSong.label = labelLabel.text;
    currentSong.image = thumbnailImageView.image;
    [self saveFavorite:currentSong];
    [UIView animateWithDuration:0.5 animations:^{
        favButton.backgroundColor = [UIColor redColor];
    }];
}
@end
