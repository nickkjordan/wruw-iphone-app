#import <Foundation/Foundation.h>

@protocol JSONConvertible;
@class Time;
@class Playlist;

@interface Show : NSObject <JSONConvertible>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSArray *hosts;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic) Time *startTime;
@property (nonatomic) Time *endTime;
@property (nonatomic, copy) NSArray *days;
@property (nonatomic, copy) NSString *infoDescription;
@property (nonatomic, copy) NSArray *playlists;

- (instancetype)initWithJson:(NSDictionary *)dict;

+ (NSString *)formatPathForDate:(NSDate *)date;

- (NSString *)hostsDisplay;

@end
