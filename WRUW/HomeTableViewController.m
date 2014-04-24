//
//  HomeTableViewController.m
//  WRUW
//
//  Created by Nick Jordan on 1/31/14.
//  Copyright (c) 2014 Nick Jordan. All rights reserved.
//

#import "HomeTableViewController.h"

@interface HomeTableViewController () <AVAudioPlayerDelegate>
{
    NSMutableArray *_archive;
    UIActivityIndicatorView *spinner;
}
@property (nonatomic, strong) ArrayDataSource *songsArrayDataSource;
@end

@implementation HomeTableViewController
@synthesize showTitle, showDescription, player;

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
    
    __block BOOL setup;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        setup = [self setupTableView];
        [spinner stopAnimating];
    });
    
    dispatch_queue_t imageQueue = dispatch_queue_create("org.wruw.app", NULL);
    if (setup) {
        int i = 0;
        for (Song *song in _archive) {
            dispatch_async(imageQueue, ^{
                [song loadImage];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                    NSArray *indexArray = [NSArray arrayWithObjects:indexPath, nil];
                    [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
                });
            });
            i++;
        }
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
    
    spinner = [[UIActivityIndicatorView alloc] init];
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    spinner.color = [UIColor blueColor];
    [self.tableView addSubview:spinner];
    
    [spinner startAnimating];
    
    [showDescription setText:[NSString stringWithFormat:@""]];
    [showTitle setText:[NSString stringWithFormat:@""]];
    showDescription.editable = NO;
    
    dispatch_queue_t myQueue = dispatch_queue_create("org.wruw.app", NULL);
    
    dispatch_async(myQueue, ^{ [self loadHomePage]; });
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SongTableViewCell" bundle:nil ] forCellReuseIdentifier:@"SongTableCellType"];
    
    // Fix for last TableView cell under tab bar
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)streamPlay:(id)sender {
    // Load the array with the sample file
    NSURL *urlAddress = [NSURL URLWithString:@"http://wruw-stream.wruw.org:443/stream.mp3"];
    
    //Create a URL object.
    player= [AVPlayer playerWithURL:urlAddress];
    [player addObserver:self forKeyPath:@"status" options:0 context:NULL];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (player.status == AVPlayerStatusReadyToPlay) {
            [player play];
        } else if (player.status == AVPlayerStatusFailed) {
            /* An error was encountered */
        }
    }
}

#pragma mark - Table view data source

- (BOOL)setupTableView
{
    TableViewCellConfigureBlock configureCell = ^(SongTableViewCell *cell, Song *song) {
        [cell configureForSong:song controlView:self];
    };
    self.songsArrayDataSource = [[ArrayDataSource alloc] initWithItems:_archive
                                                        cellIdentifier:@"SongTableViewCell"
                                                    configureCellBlock:configureCell];
    self.tableView.dataSource = self.songsArrayDataSource;
    [self.tableView registerNib:[UINib nibWithNibName:@"SongTableViewCell" bundle:nil ] forCellReuseIdentifier:@"SongTableViewCell"];
    [self.tableView reloadData];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SongTableViewCell *cell = (SongTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if ([cell isSelected]) {
        // Deselect manually.
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        return nil;
    }
    
    return indexPath;
}

@end
