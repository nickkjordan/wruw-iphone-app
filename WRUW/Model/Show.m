#import "Show.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFOnoResponseSerializer.h"
#import "ONOXMLDocument.h"
#import "Playlist.h"
#import "WRUWModule-Swift.h"

@implementation Show
{
    ONOXMLElement *showHeader;
}

@synthesize title = _title;
@synthesize url = _url;
@synthesize host = _host;
@synthesize time = _time;
@synthesize genre = _genre;
@synthesize lastShow = _lastShow;
@synthesize days = _days;
@synthesize infoDescription = _infoDescription;
@synthesize playlists = _playlists;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.host = [decoder decodeObjectForKey:@"host"];
        self.time = [decoder decodeObjectForKey:@"time"];
        self.genre = [decoder decodeObjectForKey:@"genre"];
        self.lastShow = [decoder decodeObjectForKey:@"lastShow"];
        self.days = [decoder decodeObjectForKey:@"day"];
        self.infoDescription = [decoder decodeObjectForKey:@"infoDescription"];
    }
    
    return self;
}

- (instancetype)initWithJson:(NSDictionary *)dict {
    if (self = [super init]) {
        self.title = dict[@"ShowName"];
        self.url = dict[@"ShowUrl"];
        self.host = dict[@"ShowUsers"][0][@"DJName"];
        self.time = dict[@"OnairTime"];
        self.genre = dict[@"ShowCategory"];
        self.lastShow = dict[@"lastShow"];
        self.days = dict[@"Weekdays"];
        self.infoDescription = dict[@"ShowDescription"];
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
    [encoder encodeObject:_days forKey:@"day"];
    [encoder encodeObject:_infoDescription forKey:@"infoDescription"];
}

- (NSString *)path {
    NSCharacterSet *nonLetterSet = [NSCharacterSet punctuationCharacterSet];

    NSString *base = [[_title.lowercaseString
                       componentsSeparatedByCharactersInSet:nonLetterSet]
                      componentsJoinedByString:@""];

    return [base stringByReplacingOccurrencesOfString:@" " withString:@"-"];
}

+ (NSString *)formatPathForDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";

    return [formatter stringFromDate:date];
}

- (BOOL)isEqualToShow:(Show *)show {
    
    if(!show) {
        return NO;
    }
    
    BOOL haveEqualShowTitles = (!self.title && !show.title) || [self.title isEqualToString:show.title];
    
    return haveEqualShowTitles;
}

- (BOOL)currentShowValid {
    return self.title && self.host && self.time && self.genre && self.days && self.lastShow;
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
