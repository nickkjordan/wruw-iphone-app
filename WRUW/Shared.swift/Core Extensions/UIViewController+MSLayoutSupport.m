//
//  UIViewController+MSLayoutSupport.m
//  WRUW
//
//  Created by Nick Jordan on 4/7/15.
//  Copyright (c) 2015 Nick Jordan. All rights reserved.
//

#import "UIViewController+MSLayoutSupport.h"

@implementation UIViewController (MSLayoutSupport)

- (id<UILayoutSupport>)ms_navigationBarTopLayoutGuide {
    if (self.parentViewController &&
        ![self.parentViewController isKindOfClass:UINavigationController.class]) {
        return self.parentViewController.ms_navigationBarTopLayoutGuide;
    } else {
        return self.topLayoutGuide;
    }
}

- (id<UILayoutSupport>)ms_navigationBarBottomLayoutGuide {
    if (self.parentViewController &&
        ![self.parentViewController isKindOfClass:UINavigationController.class]) {
        return self.parentViewController.ms_navigationBarBottomLayoutGuide;
    } else {
        return self.bottomLayoutGuide;
    }
}

@end
