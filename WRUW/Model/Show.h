#import <Foundation/Foundation.h>
#import "Playlist.h"

@protocol JSONConvertible;

@interface Show : NSObject <JSONConvertible>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSArray *hosts;
@property (nonatomic, copy) NSString *genre;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSArray *days;
@property (nonatomic, copy) NSString *infoDescription;
@property (nonatomic) Playlist *lastShow;
@property (nonatomic, copy) NSArray *playlists;

- (instancetype)initWithJson:(NSDictionary *)dict;

+ (NSString *)formatPathForDate:(NSDate *)date;

- (NSString *)hostsDisplay;

@end
