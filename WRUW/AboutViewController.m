//
//  AboutViewController.m
//  WRUW
//
//  Created by Nick Jordan on 4/13/15.
//  Copyright (c) 2015 Nick Jordan. All rights reserved.
//

#import "AboutViewController.h"
#import "WRUWModule-Swift.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
@synthesize appInfoText, wruwInfoText;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTextView:appInfoText];
    [self setupTextView:wruwInfoText];
}

- (void)setupTextView:(UITextView *)textView {
    [textView setUserInteractionEnabled:YES];
    [textView setEditable:NO];
    [textView setDataDetectorTypes:UIDataDetectorTypeAll];
    [textView setSelectable:YES];

    [textView setLinkTextAttributes:@{
        NSForegroundColorAttributeName: [[ThemeManager current] wruwMainOrangeColor],
        NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]
    }];
}

@end
