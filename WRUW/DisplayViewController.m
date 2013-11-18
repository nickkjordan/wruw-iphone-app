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

@interface DisplayViewController () <AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer;
    NSMutableArray *_playlists;
    UITableView *tableView;
}
@end

@implementation DisplayViewController

@synthesize currentShow;
@synthesize currentShowTitle;
@synthesize currentShowHost;
@synthesize currentShowTime;
@synthesize currentShowInfo;

-(void)loadPlaylists {
    // 1
    NSURL *showsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wruw.org/guide/%@",currentShow.url]];
    NSData *showsHtmlData = [NSData dataWithContentsOfURL:showsUrl];
    
    // 2
    TFHpple *showsParser = [TFHpple hppleWithHTMLData:showsHtmlData];
    
    // 3
    NSString *showsXpathQueryString = @"//*[@id='playlist']/p/select/option";
    NSArray *showsNodes = [showsParser searchWithXPathQuery:showsXpathQueryString];
    
    NSString *infoXpathQueryString = @"/html/body/table[2]/tr[1]/td/table/tr[2]/td[2]/p[2]";
    NSArray *infoNode = [showsParser searchWithXPathQuery:infoXpathQueryString];

    NSString *showInfo = [[infoNode[0] firstChild] content];
    showInfo = [showInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    showInfo = [showInfo stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    [currentShowInfo setText:[showInfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

    // 4
    NSMutableArray *newPlaylists = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in showsNodes) {
        // 5
        Playlist *playlist = [[Playlist alloc] init];
        [newPlaylists addObject:playlist];
        
        playlist.date = [[element firstChild] content];
        playlist.idValue = [element objectForKey:@"value"];
    }
    
    // 8
    _playlists = newPlaylists;
    [tableView reloadData];
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
    
    [self loadPlaylists];
}

- (void)viewDidAppear:(BOOL)animated
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _playlists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Playlist *thisPlaylist = [_playlists objectAtIndex:indexPath.row];
    
    [[cell textLabel] setText:thisPlaylist.date];
    
    return cell;
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