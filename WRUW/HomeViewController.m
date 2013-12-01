//
//  HomeViewController.m
//  WRUW
//
//  Created by Nick Jordan on 9/10/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "HomeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController () <AVAudioPlayerDelegate>
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation HomeViewController
@synthesize currentShowDescription, currentShowTitle;

- (void)loadHomePage{
    
    
    // 1
    NSURL *homePageUrl = [NSURL URLWithString:@"http://www.wruw.org/"];
    NSData *homePageHtmlData = [NSData dataWithContentsOfURL:homePageUrl];
    
    // 2
    TFHpple *homePageParser = [TFHpple hppleWithHTMLData:homePageHtmlData];
    
    // 3
    NSString *currentShowTitleXpathQueryString = @"/html/body/table[2]/tr[1]/td[2]/table[1]/tr[2]/td[2]/p[1]/a";
    NSString *currentShowDescriptionXpathQueryString = @"/html/body/table[2]/tr[1]/td[2]/table[1]/tr[2]/td[2]/p[1]/text()";
    NSArray *showTitleNode = [homePageParser searchWithXPathQuery:currentShowTitleXpathQueryString];
    NSArray *showDescriptionNode = [homePageParser searchWithXPathQuery:currentShowDescriptionXpathQueryString];
    
    TFHppleElement *showTitleElement = showTitleNode[0];
    NSString *showTitle = [[showTitleElement firstChild] content];
    
    TFHppleElement *showDescriptionElement = showDescriptionNode[1];
    NSString *showDescription = [showDescriptionElement content];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentShowTitle setText:showTitle];
        [currentShowDescription setText:showDescription];
    });
    
}

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

    dispatch_queue_t myQueue = dispatch_queue_create("org.wruw.app", NULL);
    
    dispatch_async(myQueue, ^{ [self loadHomePage]; });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)streamPlay:(id)sender {
    NSString *urlAddress = @"http://www.wruw.org/listen/stream.php?stream=live128";
    NSURL *urlStream = [NSURL URLWithString:urlAddress];
    AVPlayer *musicPlayer = [AVPlayer playerWithURL:urlStream];
    [musicPlayer play];
}


@end
