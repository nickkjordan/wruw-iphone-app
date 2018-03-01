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

@end
