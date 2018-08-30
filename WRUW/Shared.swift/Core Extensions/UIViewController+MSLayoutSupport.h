//
//  UIViewController+MSLayoutSupport.h
//  WRUW
//
//  Created by Nick Jordan on 4/7/15.
//  Copyright (c) 2015 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MSLayoutSupport)

- (id<UILayoutSupport>)ms_navigationBarTopLayoutGuide;

- (id<UILayoutSupport>)ms_navigationBarBottomLayoutGuide;

@end
