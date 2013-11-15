//
//  DisplayViewController.m
//  WRUW
//
//  Created by Nick Jordan on 11/15/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "DisplayViewController.h"

@interface DisplayViewController ()

@end

@implementation DisplayViewController

@synthesize currentShow;
@synthesize currentShowTitle;
@synthesize currentShowHost;
@synthesize currentShowTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//	
//    [self setTitle:[currentShow title]];
//    [currentShowHost setText:[currentShow host]];
//    [currentShowTime setText:[currentShow time]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
