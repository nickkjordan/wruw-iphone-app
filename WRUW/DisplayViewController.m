//
//  DisplayViewController.m
//  WRUW
//
//  Created by Nick Jordan on 11/15/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "DisplayViewController.h"
#import "TFHpple.h"
#import "Playlist.h"
#import <AVFoundation/AVFoundation.h>
#import "PlaylistsTableViewController.h"

@interface DisplayViewController () <AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer;
    UITableView *tableView;
    TFHpple *showsParser;
}
@end

@implementation DisplayViewController

@synthesize currentShow;
@synthesize currentShowTitle;
@synthesize currentShowHost;
@synthesize currentShowTime;
@synthesize currentShowInfo;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showPlaylistsSegue"]) {
        PlaylistsTableViewController *ptvc = [segue destinationViewController];
        
        // pass along showsParser
        
        [ptvc setCurrentShow:currentShow];
        [ptvc setCurrentParser:showsParser];
    }
}

-(void)loadInfo {
    // 1
    NSURL *showsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wruw.org/guide/%@",currentShow.url]];
    NSData *showsHtmlData = [NSData dataWithContentsOfURL:showsUrl];
    
    // 2
    showsParser = [TFHpple hppleWithHTMLData:showsHtmlData];
    
    NSString *infoXpathQueryString = @"/html/body/table[2]/tr[1]/td/table/tr[2]/td[2]/p[2]";
    NSArray *infoNode = [showsParser searchWithXPathQuery:infoXpathQueryString];

    NSString *showInfo = [[infoNode[0] firstChild] content];
    showInfo = [showInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    showInfo = [showInfo stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [currentShowInfo setText:[showInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
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
    
    NSRange wordRange = NSMakeRange(1, 5);
    NSArray *firstWords = [[currentShow.time componentsSeparatedByString:@" "] subarrayWithRange:wordRange];
    NSString *timeFrame = [firstWords componentsJoinedByString:@" "];
    
    [currentShowTitle setText:currentShow.title];
    [currentShowHost setText:[NSString stringWithFormat:@"hosted by %@", currentShow.host]];
    [currentShowTime setText:[NSString stringWithFormat:@"on %@s from %@",currentShow.day, timeFrame]];
    
    [self loadInfo];
}

- (void)viewDidAppear:(BOOL)animated
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Audio player recent show

- (IBAction)playTapped:(id)sender {
    NSString *aSongURL = [NSString stringWithFormat:@"http://in.orgware.in/testing/mp3/1.mp3"];
    // NSLog(@"Song URL : %@", aSongURL);
    
    AVPlayerItem *aPlayerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:aSongURL]];
    AVPlayer *anAudioStreamer = [[AVPlayer alloc] initWithPlayerItem:aPlayerItem];
    [anAudioStreamer play];
}

// http://in.orgware.in/testing/mp3/1.mp3

- (IBAction)togglePlayPauseTapped:(id)sender {
    AVAudioPlayer *audioPlayer;
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"01 Twin Peaks Theme" ofType:@"mp3"];
    NSURL *audioURL = [NSURL fileURLWithPath:audioPath];
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    [audioPlayer play];
}
@end