#import "Show.h"
#import "Playlist.h"
#import "WRUWModule-Swift.h"

@implementation Show

@synthesize title = _title;
@synthesize url = _url;
@synthesize hosts = _hosts;
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
        self.hosts = [decoder decodeObjectForKey:@"hosts"];
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
        self.time = dict[@"OnairTime"];
        self.genre = dict[@"ShowCategory"];
        self.lastShow = dict[@"lastShow"];
        self.days = dict[@"Weekdays"];
        self.infoDescription = dict[@"ShowDescription"];

        NSArray *users = dict[@"ShowUsers"];
        NSMutableArray *hosts = [[NSMutableArray alloc] init];
        [users enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [hosts addObject:obj[@"DJName"]];
        }];
        self.hosts = hosts;
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_url forKey:@"url"];
    [encoder encodeObject:_hosts forKey:@"hosts"];
    [encoder encodeObject:_time forKey:@"time"];
    [encoder encodeObject:_genre forKey:@"genre"];
    [encoder encodeObject:_lastShow forKey:@"lastShow"];
    [encoder encodeObject:_days forKey:@"day"];
    [encoder encodeObject:_infoDescription forKey:@"infoDescription"];
}

+ (NSString *)formatPathForDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";

    return [formatter stringFromDate:date];
}

- (NSString *)hostsDisplay {
    return [_hosts componentsJoinedByString:@", "];
}

- (BOOL)isEqualToShow:(Show *)show {
    
    if(!show) {
        return NO;
    }
    
    BOOL haveEqualShowTitles = (!self.title && !show.title) || [self.title isEqualToString:show.title];
    
    return haveEqualShowTitles;
}

- (BOOL)currentShowValid {
    return self.title && self.hosts && self.time && self.genre && self.days && self.lastShow;
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
