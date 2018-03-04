#import "Song.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "AFOnoResponseSerializer.h"
#import "ONOXMLDocument.h"
#import "WRUWModule-Swift.h"

@implementation Song

@synthesize artist = _artist;
@synthesize album = _album;
@synthesize songName = _songName;
@synthesize label = _label;
@synthesize image = _image;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.songName = [decoder decodeObjectForKey:@"songName"];
        self.artist = [decoder decodeObjectForKey:@"artist"];
        self.album = [decoder decodeObjectForKey:@"album"];
        self.label = [decoder decodeObjectForKey:@"label"];
        self.image = [decoder decodeObjectForKey:@"image"];
    }
    return self;
}

-(instancetype)initWithJson:(NSDictionary *)dict {
    if (self = [super init]) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"iTunesArtwork"
                                                         ofType:@"png"];
        
        self.image = [UIImage imageWithContentsOfFile:path];

        self.songName = dict[@"SongName"];
        self.artist = dict[@"ArtistName"];
        self.album = dict[@"DiskName"];
        self.label = dict[@"LabelName"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_songName forKey:@"songName"];
    [encoder encodeObject:_artist forKey:@"artist"];
    [encoder encodeObject:_album forKey:@"album"];
    [encoder encodeObject:_label forKey:@"label"];
    [encoder encodeObject:_image forKey:@"image"];
}

- (BOOL)isEqualToSong:(Song *)song {
    if(!song) {
        return NO;
    }
    
    BOOL haveEqualArtistNames = (!self.artist && !song.artist) || [self.artist isEqualToString:song.artist];
    BOOL haveEqualSongTitles = (!self.songName && !song.songName) || [self.songName isEqualToString:song.songName];
    
    return haveEqualArtistNames && haveEqualSongTitles;
}

-(NSString *)formatForURL:(NSString *)string {
    NSString *returnString = [string stringByReplacingOccurrencesOfString:@" "
                                                               withString:@"+"];
    returnString = [returnString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return returnString;
}

#pragma mark - NSObject

- (NSUInteger)hash {
    return [self.artist hash] ^ [self.songName hash];
}

-(BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToSong:other];
}

@end
