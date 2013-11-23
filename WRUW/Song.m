//
//  Song.m
//  WRUW
//
//  Created by Nick Jordan on 11/19/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "Song.h"

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

@end
