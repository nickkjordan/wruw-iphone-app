//
//  Song.m
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "Song.h"
#import "TFHpple.h"

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

-(void)loadImage {
    
    NSString *urlQuery;
    
    if (self.artist && self.album) {
        NSString *artistUrlString = [self.artist stringByReplacingOccurrencesOfString:@" "
                                                                           withString:@"+"];
        NSString *albumUrlString = [self.album stringByReplacingOccurrencesOfString:@" "
                                                                         withString:@"+"];
        
        urlQuery = [NSString stringWithFormat:@"%@+%@",artistUrlString,albumUrlString];
        
    } else if (self.album) {
        NSString *albumUrlString = [self.album stringByReplacingOccurrencesOfString:@" "
                                                                         withString:@"+"];
        urlQuery = albumUrlString;
    } else {
        NSString *artistUrlString = [self.artist stringByReplacingOccurrencesOfString:@" "
                                                                           withString:@"+"];
        urlQuery = artistUrlString;
    }
    
    // Complete url
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.google.com/images?q=%@&sout=1",urlQuery]];
    // Send a synchronous request
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *htmlData = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    if (error == nil) {
        // 2
        TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
        
        // 3
        NSString *xpathQueryString = @"//*[@id='ires']/table/tr[1]/td[1]/a/img";
        NSArray *node = [parser searchWithXPathQuery:xpathQueryString];
        
        TFHppleElement *img = [node firstObject];
        
        NSString *imgUrl = [img objectForKey:@"src"];
        
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
        
        UIImage *albumImage = [UIImage imageWithData:imgData];
        
        self.image = albumImage;
    }
    
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
