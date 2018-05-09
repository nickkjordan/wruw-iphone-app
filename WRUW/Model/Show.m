#import "Show.h"
#import "WRUWModule-Swift.h"

@implementation Show

@synthesize title = _title;
@synthesize url = _url;
@synthesize hosts = _hosts;
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize genre = _genre;
@synthesize days = _days;
@synthesize infoDescription = _infoDescription;
@synthesize playlists = _playlists;

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.url = [decoder decodeObjectForKey:@"url"];
        self.hosts = [decoder decodeObjectForKey:@"hosts"];

        if (self.hosts == nil) {
            NSString *host = [decoder decodeObjectForKey:@"host"];
            self.hosts = [[NSArray alloc] initWithObjects:host, nil];
        }

        self.startTime = [decoder decodeObjectForKey:@"startTime"];
        self.endTime = [decoder decodeObjectForKey:@"endTime"];
        self.genre = [decoder decodeObjectForKey:@"genre"];

        NSObject *days = [decoder decodeObjectForKey:@"day"];
        if ([days isKindOfClass:NSArray.class]) {
            self.days = (NSArray *)days;
        } else {
            self.days = [[NSArray alloc] initWithObjects:days, nil];
        }

        self.infoDescription = [decoder decodeObjectForKey:@"infoDescription"];
    }
    
    return self;
}

- (instancetype)initWithJson:(NSDictionary *)dict {
    if (self = [super init]) {
        self.title = dict[@"ShowName"];
        self.url = dict[@"ShowUrl"];
        self.startTime = [[Time alloc] initWithString:dict[@"OnairTime"]];
        self.endTime = [[Time alloc] initWithString:dict[@"OffairTime"]];
        self.genre = dict[@"ShowCategory"];
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

- (id)toJSONObject {
    NSMutableArray *hosts = [[NSMutableArray alloc] init];

    [self.hosts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [hosts addObject:@{@"DJName": obj}];
    }];

    return @{
             @"ShowName": _title,
             @"ShowUrl": _url,
             @"OnairTime": [self.startTime toJSON],
             @"OffairTime": [self.endTime toJSON],
             @"ShowCategory": self.genre,
             @"Weekdays": self.days,
             @"ShowDescription": self.infoDescription,
             @"ShowUsers": hosts
             };
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_title forKey:@"title"];
    [encoder encodeObject:_url forKey:@"url"];
    [encoder encodeObject:_hosts forKey:@"hosts"];
    [encoder encodeObject:_startTime forKey:@"startTime"];
    [encoder encodeObject:_endTime forKey:@"endTime"];
    [encoder encodeObject:_genre forKey:@"genre"];
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
    return self.title && self.hosts && self.startTime && self.genre && self.days;
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
