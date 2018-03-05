#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JSONConvertible;

#pragma clang diagnostic push

// To get rid of 'No protocol definition found' warnings which are not accurate
#pragma clang diagnostic ignored "-W#pragma-messages"
@interface Song : NSObject <NSCoding, JSONConvertible>
#pragma clang diagnostic pop

@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *songName;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) UIImage *image;

-(BOOL)isEqualToSong:(Song *)song;
-(NSString *)formatForURL:(NSString *)string;

- (instancetype)initWithJson:(NSDictionary *)dict;

@end
