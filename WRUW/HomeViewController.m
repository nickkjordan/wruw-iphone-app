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
#import "WRUWModule-Swift.h"
#import "DisplayViewController.h"
#import "Show.h"
#import "CBStoreHouseRefreshControl.h"
#import "ARAnalytics.h"

@interface HomeViewController () <AVAudioPlayerDelegate>
{
    NSMutableArray *_archive;
    UIActivityIndicatorView *spinner;
}
@property (nonatomic, strong) ArrayDataSource *songsArrayDataSource;
@property (nonatomic, strong) Show *currentShow;
@property (nonatomic, strong) CBStoreHouseRefreshControl *storeHouseRefreshControl;
@property (nonatomic, strong) StreamPlayView *streamPlay;
@end

@implementation HomeViewController
@synthesize showTitle, showDescription, showDescriptionHeight, showViewHeight, infoView, showContainer, hostLabel;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showDisplaySegue"]) {
        DisplayViewController *dvc = [segue destinationViewController];
        
        [dvc setCurrentShow:_currentShow];
    }
}

- (void)checkConnection
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFOnoResponseSerializer HTMLResponseSerializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager GET:@"http://www.wruw.org" parameters:nil success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
        [self loadHomePage:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Connection" message:@"Make sure you are connected to the internet, then drag down on \"Now Playing\" to reload." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        
        [self.storeHouseRefreshControl finishingLoading];
        [spinner stopAnimating];
        return;
    }];
    
}

- (void)loadHomePage:(ONOXMLDocument *)homePageHtmlData {
    
    Show *newShow = [[Show alloc] init];
    
    // Create XPath strings
    NSString *currentShowTitleXpathQueryString = @"//*[@id='main-nav']/div[1]/div/div[2]/div/div/div[2]/div[1]/span/a";
    
    ONOXMLElement *showTitleNode = [homePageHtmlData firstChildWithXPath:currentShowTitleXpathQueryString];
    
    NSString *url = [[showTitleNode attributes] objectForKey:@"href"];
    
    newShow.url = url;
    [newShow loadInfo:^(){
        self.moreInfoButton.enabled = YES;
        
        if (_archive.count == 0) {
            [self loadCurrentPlaylist];
        }
        if (![newShow isEqual:_currentShow]) {
            _currentShow = newShow;
            dispatch_async(dispatch_get_main_queue(), ^{
                [showTitle setText:_currentShow.title];
                [hostLabel setText:_currentShow.host];
            });
            
            // remove current playlist
            _archive = [NSMutableArray array];
            [self loadCurrentPlaylist];
        } else {
            [self updateCurrentPlaylist];
        }
    }];
    
}

- (void)loadCurrentPlaylist {
    _archive = [NSMutableArray arrayWithArray:[[[_currentShow.lastShow loadSongs] reverseObjectEnumerator] allObjects]];

    __block BOOL setup;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        setup = [self setupTableView];
        [spinner stopAnimating];
    });
    
    int i = 0;
    [self.tableView beginUpdates];
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
    [self.tableView endUpdates];
    
    [self.storeHouseRefreshControl finishingLoading];
}

- (void)updateCurrentPlaylist {
    
    NSMutableArray *updatedPlaylist = [_currentShow.lastShow loadSongs];
    
    // 8
    NSMutableArray *newSongs = [NSMutableArray arrayWithArray:[[updatedPlaylist reverseObjectEnumerator] allObjects]];
    [newSongs removeObjectsInArray:[NSMutableArray arrayWithArray:[[_archive reverseObjectEnumerator] allObjects]]];
    
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                           NSMakeRange(0,[newSongs count])];
    [_archive insertObjects:newSongs atIndexes:indexes];
    
    int i = 0;
    [self.tableView beginUpdates];
    for (Song *song in newSongs) {
        [song loadImage:^void () {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                NSArray *indexArray = [NSArray arrayWithObjects:indexPath, nil];
                [self.tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
            });
        }];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        NSArray *indexArray = [NSArray arrayWithObjects:indexPath, nil];
        [self.tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
        
        i++;
    }
    [self.tableView endUpdates];
    
    [self.storeHouseRefreshControl finishingLoading];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Now Playing"];
    [ARAnalytics event:@"Screen view" withProperties:@{
                                                       @"screen": @"Home View"
                                                       }];
    
    self.tableView.delegate = self;
    
    _currentShow = [[Show alloc] init];
    
    showContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    showContainer.layer.shadowOffset = CGSizeMake(0, 1);
    showContainer.layer.shadowOpacity = 0.36;
    showContainer.layer.shadowRadius = 0.5;
    showContainer.clipsToBounds = NO;
    
    spinner = [[UIActivityIndicatorView alloc] init];
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    spinner.color = [UIColor orangeColor];
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
    
    self.streamPlay = [[StreamPlayView alloc] initWithFrame:CGRectMake(0, 0, 140, 150)];
    [self.showView addSubview:self.streamPlay];
    
    self.storeHouseRefreshControl = [CBStoreHouseRefreshControl
                                     attachToScrollView:self.tableView
                                     target:self
                                     refreshAction:@selector(refreshTriggered)
                                     plist:@"WruwStorehouseIconList"
                                     color:[UIColor darkGrayColor]
                                     lineWidth:1.5
                                     dropHeight:100
                                     scale:1.5
                                     horizontalRandomness:150
                                     reverseLoadingAnimation:YES
                                     internalAnimationFactor:0.5];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(checkConnection) userInfo:nil repeats:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self.streamPlay
                                            selector:@selector(didAppear)
                                                name:UIApplicationDidBecomeActiveNotification
                                              object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self.streamPlay becomeFirstResponder];
    
    [self.streamPlay didAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //End recieving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self.streamPlay resignFirstResponder];
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

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.storeHouseRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.storeHouseRefreshControl scrollViewDidEndDragging];
}

- (void)refreshTriggered
{
    [self checkConnection];
}

@end
