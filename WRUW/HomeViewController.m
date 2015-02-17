//
//  HomeTableViewController.m
//  WRUW
//
//  Created by Nick Jordan on 1/31/14.
//  Copyright (c) 2014 Nick Jordan. All rights reserved.
//

#import "HomeViewController.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFOnoResponseSerializer.h"
#import "Ono.h"

@interface HomeViewController () <AVAudioPlayerDelegate>
{
    NSMutableArray *_archive;
    UIActivityIndicatorView *spinner;
}
@property (nonatomic, strong) ArrayDataSource *songsArrayDataSource;
@end

@implementation HomeViewController
@synthesize showTitle, showDescription, player, showDescriptionHeight, showViewHeight, infoView, showContainer;

- (void)checkConnection{

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer HTMLResponseSerializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:@"http://www.wruw.org" parameters:nil success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
        [self loadHomePage:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        return;
    }];
    
}

- (void)loadHomePage:(ONOXMLDocument *)homePageHtmlData {
    
    // Create XPath strings
    NSString *currentShowTitleXpathQueryString = @"/html/body/table[2]/tr[1]/td[2]/table[1]/tr[2]/td[2]/p[1]/a";
    
    ONOXMLElement *showTitleNode = [homePageHtmlData firstChildWithXPath:currentShowTitleXpathQueryString];
    
    NSString *title = [showTitleNode stringValue];
    NSString *url = [[showTitleNode attributes] objectForKey:@"href"];
    NSString *description = showTitleNode.nextSibling.nextSibling.stringValue;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [showTitle setText:title];
        [showDescription setText:description];
        
        [self resizeNowPlaying];
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


- (void)resizeNowPlaying {
    CGSize sizeThatShouldFitTheContent = [showDescription sizeThatFits:showDescription.frame.size];
    showDescriptionHeight.constant = sizeThatShouldFitTheContent.height;
    
    showViewHeight.constant = 85 + sizeThatShouldFitTheContent.height;
    
    infoView.frame = CGRectMake(0, 0, infoView.frame.size.width, showViewHeight.constant + 10);
    self.tableView.tableHeaderView = infoView;
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
        }
        
    }
    
    // 8
    _archive = [NSMutableArray arrayWithArray:[[newSongs reverseObjectEnumerator] allObjects]];
    
    __block BOOL setup;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        setup = [self setupTableView];
        [spinner stopAnimating];
    });
    
    int i = 0;
    for (Song *song in _archive) {
        [song loadImage:^void () {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                NSArray *indexArray = [NSArray arrayWithObjects:indexPath, nil];
                [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
            });
        }];
        
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
    
    self.tableView.delegate = self;
    
    showContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    showContainer.layer.shadowOffset = CGSizeMake(0, 1);
    showContainer.layer.shadowOpacity = 0.36;
    showContainer.layer.shadowRadius = 0.5;
    showContainer.clipsToBounds = NO;
    
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
    
    dispatch_async(myQueue, ^{ [self checkConnection]; });
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SongTableViewCell" bundle:nil ] forCellReuseIdentifier:@"SongTableCellType"];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    // Fix for last TableView cell under tab bar
//    self.edgesForExtendedLayout = UIRectEdgeAll;
//    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    // Set navigation bar
    self.navigationBar.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)streamPlay:(id)sender {
    if(player.rate == 1.0)//means pause
    {
        //This will change the image of the button to play image
        //[sender setSelected:NO];
        [player pause];
    }
    else {
        // Create a URL object.
        NSURL *urlAddress = [NSURL URLWithString:@"http://wruw-stream.wruw.org:443/stream.mp3"];
        // And send it to the avplayer
        player= [AVPlayer playerWithURL:urlAddress];
        
        //This will change the image of the button to pause image
        //[sender setSelected:YES];
        [player addObserver:self forKeyPath:@"status" options:0 context:NULL];
    }
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
    
    return true;
}

#pragma mark – Table view delegate

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

#pragma mark - Navigation Bar delegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

@end
