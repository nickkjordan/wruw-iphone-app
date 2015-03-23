//
//  Playlist.m
//  WRUW
//
//  Created by Nick Jordan on 11/17/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "Playlist.h"
#import "TFHpple.h"
#import "Song.h"

@implementation Playlist

@synthesize date = _date;
@synthesize idValue = _idValue;

-(NSMutableArray *)loadSongs {
    NSURL *archiveUrl = [NSURL URLWithString:self.idValue];
    NSData *archiveHtmlData = [NSData dataWithContentsOfURL:archiveUrl];
    
    // 2
    TFHpple *archiveParser = [TFHpple hppleWithHTMLData:archiveHtmlData];
    
    // 3
    NSString *archiveXpathQueryString = @"//*[@id='show-playlist']/li[position()>1]";
    NSArray *archiveNodes = [archiveParser searchWithXPathQuery:archiveXpathQueryString];
    
    // 4
    NSMutableArray *newSongs = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in archiveNodes) {
        // 5
        Song *song = [[Song alloc] init];
        [newSongs addObject:song];
        
        NSArray *songInfo = [element children];
        
        song.songName = [[songInfo[0] firstChild] content];
        song.artist = [[songInfo[1] firstChild] content];
        song.album = [[songInfo[2] firstChild] content];
        song.label = [[songInfo[3] firstChild] content];
    }
    
    return newSongs;
}

@end
