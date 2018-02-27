#import "Playlist.h"
#import "TFHpple.h"
#import "Song.h"
#import "WRUWModule-Swift.h"

@implementation Playlist

@synthesize date = _date;
@synthesize idValue = _idValue;
@synthesize songs = _songs;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.idValue forKey:@"ID"];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        self.idValue = [aDecoder decodeObjectForKey:@"ID"];
    }
    return self;
}

-(instancetype)initWithJson:(NSDictionary *)dict {
    if (self = [super init]) {
        NSMutableArray *songs = [[NSMutableArray alloc] init];

        for (NSDictionary *song in dict[@"songs"]) {
            Song *playlistSong = [[Song alloc] initWithJson:song];

            [songs addObject:playlistSong];
        }

        self.songs = songs;
        self.idValue = dict[@"PlaylistID"];
        self.date = dict[@"PlaylistDate"];
    }

    return self;
}

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
        
        song.songName = [[songInfo[1] firstChild] content];
        song.artist = [[songInfo[0] firstChild] content];
        song.album = [[songInfo[2] firstChild] content];
        song.label = [[songInfo[3] firstChild] content];
    }
    
    return newSongs;
}

@end
