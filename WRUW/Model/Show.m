//
//  Show.m
//  WRUWShowTest
//
//  Created by Nick Jordan on 11/14/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "Show.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFOnoResponseSerializer.h"
#import "ONOXMLDocument.h"

@implementation Show

@synthesize title = _title;
@synthesize url = _url;
@synthesize host = _host;
@synthesize time = _time;
@synthesize genre = _genre;
@synthesize lastShow = _lastShow;
@synthesize day = _day;
@synthesize infoDescription = _infoDescription;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.host = [decoder decodeObjectForKey:@"host"];
        self.time = [decoder decodeObjectForKey:@"time"];
        self.genre = [decoder decodeObjectForKey:@"genre"];
        self.lastShow = [decoder decodeObjectForKey:@"lastShow"];
        self.day = [decoder decodeObjectForKey:@"day"];
        self.infoDescription = [decoder decodeObjectForKey:@"infoDescription"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_url forKey:@"url"];
    [encoder encodeObject:_host forKey:@"host"];
    [encoder encodeObject:_time forKey:@"time"];
    [encoder encodeObject:_genre forKey:@"genre"];
    [encoder encodeObject:_lastShow forKey:@"lastShow"];
    [encoder encodeObject:_day forKey:@"day"];
    [encoder encodeObject:_infoDescription forKey:@"infoDescription"];
}

- (BOOL)isEqualToShow:(Show *)show {
    
    if(!show) {
        return NO;
    }
    
    BOOL haveEqualShowTitles = (!self.title && !show.title) || [self.title isEqualToString:show.title];
    
    return haveEqualShowTitles;
}

- (void)loadInfo:(LoadShowBlock)successBlock {
    if (self.title && self.host && self.time && self.genre && self.day && self.lastShow) {
        return;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer HTMLResponseSerializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:self.url parameters:nil success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
        [self parseShowInfo:responseObject];
        successBlock();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        return;
    }];
}

- (void)parseShowInfo:(ONOXMLDocument *)data {
    ONOXMLElement *showHeader = [data firstChildWithXPath:@"//*[@id='main']/div/article"];
    
    self.title = [[showHeader firstChildWithCSS:@".entry-title"] stringValue];
    self.host = @"";
    [showHeader enumerateElementsWithXPath:@"header/p[1]/a" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            self.host = element.stringValue;
        } else {
            self.host = [NSString stringWithFormat:@"%@, %@", self.host, element.stringValue];
        }
    }];
    self.day = @"";
    [showHeader enumerateElementsWithXPath:@"header/ul/li/strong" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            self.day = [element.stringValue stringByReplacingOccurrencesOfString:@":" withString:@""];
        } else {
            self.day = [NSString stringWithFormat:@"%@, %@", self.day, [element.stringValue stringByReplacingOccurrencesOfString:@":" withString:@""]];
        }
    }];
    self.genre = @"";
    [showHeader enumerateElementsWithXPath:@"header/p[3]/a" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        if (idx == 0) {
            self.genre = element.stringValue;
        } else {
            self.genre = [NSString stringWithFormat:@"%@, %@", self.genre, element.stringValue];
        }
    }];
    self.time = [[showHeader firstChildWithXPath:@"header/ul/li"] stringValue];
    self.infoDescription = [[showHeader firstChildWithXPath:@"div/p"] stringValue];
    self.lastShow = [[Playlist alloc] init];
    self.lastShow.idValue = [[showHeader firstChildWithXPath:@"//*[@id='playlist-select']/option[2]/@value"] stringValue];
    self.lastShow.date = [[showHeader firstChildWithXPath:@"//*[@id='playlist-select']/option[2]"] stringValue];
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
