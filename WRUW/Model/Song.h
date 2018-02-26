#import <Foundation/Foundation.h>

@protocol JSONConvertible;

@interface Song : NSObject <NSCoding, JSONConvertible>

@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *imageUrl;

-(BOOL)isEqualToSong:(Song *)song;
-(void)loadImage:(void (^)())succeeded;
-(NSString *)formatForURL:(NSString *)string;

- (instancetype)initWithJson:(NSDictionary *)dict;

@end
