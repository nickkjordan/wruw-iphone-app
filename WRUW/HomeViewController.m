//
//  HomeViewController.m
//  WRUW
//
//  Created by Nick Jordan on 9/10/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "HomeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TFHpple.h"
#import "Song.h"
#include "Playlist.h"
#import "SongTableViewCell.h"

@interface HomeViewController () <AVAudioPlayerDelegate>
{
    NSMutableArray *_archive;
    UIActivityIndicatorView *spinner;
}
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation HomeViewController
@synthesize showTitle, showDescription;

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
    NSString *title = [[showTitleElement firstChild] content];
    
    NSString * url = [showTitleElement objectForKey:@"href"];

    
    TFHppleElement *showDescriptionElement = showDescriptionNode[1];
    NSString *description = [showDescriptionElement content];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [showTitle setText:title];
        [showDescription setText:description];
    });
    
    // 1
    NSURL *showsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wruw.org%@",url]];
    NSData *showsHtmlData = [NSData dataWithContentsOfURL:showsUrl];
    
    // 2
    TFHpple *showsParser = [TFHpple hppleWithHTMLData:showsHtmlData];
    
    // 3
    NSString *showsXpathQueryString = @"//*[@id='playlist']/p/select/option";
    NSArray *showsNodes = [showsParser searchWithXPathQuery:showsXpathQueryString];
    
    TFHppleElement *element = [showsNodes objectAtIndex:1];
    
    Playlist *recentPlaylist = [[Playlist alloc] init];
    recentPlaylist.date = [[element firstChild] content];
    recentPlaylist.idValue = [element objectForKey:@"value"];
    
    [self loadSongs:url playlist:recentPlaylist];
}

-(void)loadSongs:(NSString *)url playlist:(Playlist*)currentPlaylist {
    
    NSString *showId = [url stringByReplacingOccurrencesOfString:@"/guide/show.php?"
                            withString:@""];
    // 1
    NSURL *archiveUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wruw.org/guide/playlists.php?%@&playlist_id=%@",showId,currentPlaylist.idValue]];
    NSData *archiveHtmlData = [NSData dataWithContentsOfURL:archiveUrl];
    
    // 2
    TFHpple *archiveParser = [TFHpple hppleWithHTMLData:archiveHtmlData];
    
    // 3
    NSString *archiveXpathQueryString = @"/html/body/table[2]/tr[1]/td/table/tr[2]/td[2]/table/tr[position()>1 and not(contains(@id, 'comments'))]";
    NSArray *archiveNodes = [archiveParser searchWithXPathQuery:archiveXpathQueryString];
    
    // 4
    NSMutableArray *newSongs = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in archiveNodes) {
        // 5
        Song *song = [[Song alloc] init];
        [newSongs addObject:song];
        
        NSArray *songInfo = [element children];
        
        for (int i = 1; i < [songInfo count] - 3; i++) {
            switch (i) {
                case 3: // set song.artist
                {
                    NSString *artist = [[songInfo[i] firstChild] content];
                    artist = [artist stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    artist = [artist stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                    song.artist = [artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
                    break;
                    
                case 5: // set song.title
                {
                    NSString *songTitle = [[songInfo[i] firstChild] content];
                    songTitle = [songTitle stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    songTitle = [songTitle stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                    song.songName = [songTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
                    break;
                    
                case 7: // set song.album
                {
                    NSString *album = [[songInfo[i] firstChild] content];
                    album = [album stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    album = [album stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                    song.album = [album stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
                    break;
                    
                case 9: // set song.label
                {
                    NSString *label = [[songInfo[i] firstChild] content];
                    label = [label stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                    label = [label stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                    song.label = [label stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                }
                    break;
                    
                default:
                    break;
            }
            NSString *path = [[NSBundle mainBundle] pathForResource:@"iTunesArtwork" ofType:@"png"];
            song.image = [UIImage imageWithContentsOfFile:path];
        }
        
    }

    // 8
    _archive = [[newSongs reverseObjectEnumerator] allObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [spinner stopAnimating];
        [self.tableView reloadData];
    });
    
    
    dispatch_queue_t imageQueue = dispatch_queue_create("org.wruw.app", NULL);
    int i = 0;
    for (Song *song in _archive) {
        dispatch_async(imageQueue, ^{
            [song loadImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView beginUpdates];
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:i inSection:0];
                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                [self.tableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            });
        });
        i++;
    }
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
    
    spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 400, 20, 30)];
    [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    spinner.color = [UIColor blueColor];
    [self.tableView addSubview:spinner];
    
    [spinner startAnimating];
    
    [showDescription setText:[NSString stringWithFormat:@""]];
    [showTitle setText:[NSString stringWithFormat:@""]];
    	
    dispatch_queue_t myQueue = dispatch_queue_create("org.wruw.app", NULL);
    
    dispatch_async(myQueue, ^{ [self loadHomePage]; });
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SongTableViewCell" bundle:nil ] forCellReuseIdentifier:@"SongTableCellType"];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _archive.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongTableViewCell";
    UITableView *c = self.tableView;
    
    SongTableViewCell *cell = (SongTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    Song *thisSong = [_archive objectAtIndex:indexPath.row];
    
    cell.nameLabel.text = thisSong.songName;
    cell.albumLabel.text = thisSong.album;
    cell.artistLabel.text = thisSong.artist;
    cell.labelLabel.text = thisSong.label;
    [cell.thumbnailImageView setImage:thisSong.image forState:UIControlStateNormal];
    cell.currentSong = thisSong;
    cell.ctrl = c;
    
    return cell;
}



@end
