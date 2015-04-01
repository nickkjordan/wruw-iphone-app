//
//  UIColor_WruwColors.h
//  WRUW
//
//  Created by Nick Jordan on 4/1/15.
//  Copyright (c) 2015 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (WruwColors)

+ (UIColor *)wruwColor;

@end

@implementation UIColor (WruwColors)

+ (UIColor *)wruwColor {
    return [UIColor colorWithRed: (253.0/255.0) green: (159.0/255.0) blue: (47.0/255.0) alpha: 1.0];
}

@end
