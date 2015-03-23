//
//  Song.m
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "Song.h"
#import "TFHpple.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import "AFOnoResponseSerializer.h"
#import "ONOXMLDocument.h"

@implementation Song

@synthesize artist = _artist;
@synthesize album = _album;
@synthesize songName = _songName;
@synthesize label = _label;
@synthesize imageUrl = _imageUrl;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.songName = [decoder decodeObjectForKey:@"songName"];
        self.artist = [decoder decodeObjectForKey:@"artist"];
        self.album = [decoder decodeObjectForKey:@"album"];
        self.label = [decoder decodeObjectForKey:@"label"];
        self.imageUrl = [decoder decodeObjectForKey:@"image"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_songName forKey:@"songName"];
    [encoder encodeObject:_artist forKey:@"artist"];
    [encoder encodeObject:_album forKey:@"album"];
    [encoder encodeObject:_label forKey:@"label"];
    [encoder encodeObject:_imageUrl forKey:@"image"];
}

- (BOOL)isEqualToSong:(Song *)song {
    
    if(!song) {
        return NO;
    }
    
    BOOL haveEqualArtistNames = (!self.artist && !song.artist) || [self.artist isEqualToString:song.artist];
    BOOL haveEqualSongTitles = (!self.songName && !song.songName) || [self.songName isEqualToString:song.songName];
    
    return haveEqualArtistNames && haveEqualSongTitles;
}

-(void)loadImage:(void (^)())succeeded {
    
    NSString *urlQuery;
    
    if (self.artist && self.album) {
        NSString *artistUrlString = [self formatForURL:self.artist];
        NSString *albumUrlString = [self formatForURL:self.album];
        
        urlQuery = [NSString stringWithFormat:@"%@+%@",artistUrlString,albumUrlString];
        
    } else if (self.album) {
        NSString *albumUrlString = [self formatForURL:self.album];
        urlQuery = albumUrlString;
    } else {
        NSString *artistUrlString = [self formatForURL:self.artist];
        urlQuery = artistUrlString;
    }
    
    // Complete url
    NSString *url = [NSString stringWithFormat:@"https://www.google.com/images?q=%@&sout=1",urlQuery];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // make request for first image in google search results with
    // https://github.com/AFNetworking/AFOnoResponseSerializer
    //
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer HTMLResponseSerializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDocument) {
        for (ONOXMLElement *element in [responseDocument XPath:@"//*[@id='ires']/table/tr[1]/td[1]/a/img"]) {
            _imageUrl =[element valueForAttribute:@"src"];
            succeeded();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", [error localizedDescription]);
    }];
    
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
