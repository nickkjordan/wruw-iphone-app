#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JSONConvertible;

@interface Song : NSObject <NSCoding, JSONConvertible>

@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) UIImage *image;

-(BOOL)isEqualToSong:(Song *)song;
-(NSString *)formatForURL:(NSString *)string;

- (instancetype)initWithJson:(NSDictionary *)dict;

@end
