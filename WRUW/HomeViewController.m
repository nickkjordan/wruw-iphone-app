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
@synthesize showTitle, showDescription, player, showDescriptionHeight, showViewHeight, infoView, showContainer, hostLabel, button;

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
    NSString *currentShowTitleXpathQueryString = @"//*[@id='main-nav']/div[1]/div/div[2]/div/div/div[2]/div[1]/span/a";
    
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
    NSURL *showsUrl = [NSURL URLWithString:url];
    NSData *showsHtmlData = [NSData dataWithContentsOfURL:showsUrl];
    
    // 2
    TFHpple *showsParser = [TFHpple hppleWithHTMLData:showsHtmlData];
    
    NSString *hostXpath = @"//*[@id='main']/div/article/header/p[1]/a";
    NSArray *hostsNodes = [showsParser searchWithXPathQuery:hostXpath];
    NSString *hostNames = @"";
    for (TFHppleElement *host in hostsNodes) {
        if (hostNames.length > 0) {
            hostNames = [@[hostNames, host.firstChild.content] componentsJoinedByString:@", "];
        } else {
            hostNames = host.firstChild.content;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [hostLabel setText:hostNames];
    });
    
    // 3
    NSString *showsXpathQueryString = @"//*[@id='playlist-select']/option";
    NSArray *showsNodes = [showsParser searchWithXPathQuery:showsXpathQueryString];
    
    TFHppleElement *element = [showsNodes objectAtIndex:1];
    
    Playlist *recentPlaylist = [[Playlist alloc] init];
    recentPlaylist.date = [[element firstChild] content];
    recentPlaylist.idValue = [element objectForKey:@"value"];
    
    NSMutableArray *newSongs = [recentPlaylist loadSongs];
    
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


- (void)resizeNowPlaying {
    CGSize sizeThatShouldFitTheContent = [showDescription sizeThatFits:showDescription.frame.size];
    showDescriptionHeight.constant = sizeThatShouldFitTheContent.height;
    
    showViewHeight.constant = 85 + sizeThatShouldFitTheContent.height;
    
    infoView.frame = CGRectMake(0, 0, infoView.frame.size.width, showViewHeight.constant + 10);
    self.tableView.tableHeaderView = infoView;
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
    [hostLabel setText:[NSString stringWithFormat:@""]];
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
    
    [button setImage:[UIImage imageNamed:@"play-arrow-128.png"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"pause-128.png"] forState:UIControlStateSelected | UIControlStateHighlighted];
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
        [sender setSelected:NO];
        [player pause];
    }
    else {
        // Create a URL object.
        NSURL *urlAddress = [NSURL URLWithString:@"http://wruw-stream.wruw.org:443/stream.mp3"];
        // And send it to the avplayer
        if (player != nil)
            [player removeObserver:self forKeyPath:@"status"];
        player= [AVPlayer playerWithURL:urlAddress];
        
        //This will change the image of the button to pause image
        [sender setSelected:YES];
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
