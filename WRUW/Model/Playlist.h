#import <Foundation/Foundation.h>

@protocol JSONConvertible;

@interface Playlist : NSObject <JSONConvertible>

@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *idValue;
@property (nonatomic, copy) NSArray *songs;

-(instancetype)initWithJson:(NSDictionary *)dict;

@end
