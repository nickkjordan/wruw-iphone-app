//
//  Show.m
//  WRUWShowTest
//
//  Created by Nick Jordan on 11/14/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "Show.h"

@implementation Show

@synthesize title = _title;
@synthesize url = _url;
@synthesize host = _host;
@synthesize time = _time;
@synthesize genre = _genre;
@synthesize lastShowUrl = _lastShowUrl;
@synthesize day = _day;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.host = [decoder decodeObjectForKey:@"host"];
        self.time = [decoder decodeObjectForKey:@"time"];
        self.genre = [decoder decodeObjectForKey:@"genre"];
        self.lastShowUrl = [decoder decodeObjectForKey:@"lastShowUrl"];
        self.day = [decoder decodeObjectForKey:@"day"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_url forKey:@"url"];
    [encoder encodeObject:_host forKey:@"host"];
    [encoder encodeObject:_time forKey:@"time"];
    [encoder encodeObject:_genre forKey:@"genre"];
    [encoder encodeObject:_lastShowUrl forKey:@"lastShowUrl"];
    [encoder encodeObject:_day forKey:@"day"];
}

- (BOOL)isEqualToShow:(Show *)show {
    
    if(!show) {
        return NO;
    }
    
    BOOL haveEqualShowTitles = (!self.title && !show.title) || [self.title isEqualToString:show.title];
    
    return haveEqualShowTitles;
}

#pragma mark - NSObject

- (NSUInteger)hash {
    return [self.title hash];
}

-(BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToShow:other];
}

@end
