#import "HomeViewController.h"
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

- (void)loadHomePage {
    CurrentShow *currentShowService = [[CurrentShow alloc] init];

    [currentShowService requestWithCompletion:^(WruwResult *result) {
        if (result.success) {
            Show *newShow = (Show *)[result success];

            self.moreInfoButton.enabled = YES;
    
            if (![newShow isEqual:_currentShow]) {
                _currentShow = newShow;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [showTitle setText:_currentShow.title];
                    [hostLabel setText:_currentShow.host];
                });
    
                // remove current playlist
                [self.tableView loadWithShow:newShow date:[[NSDate alloc] init]];
                _archive = [NSMutableArray array];
//                [self loadCurrentPlaylist];
            } else {
                [self updateCurrentPlaylist];
            }
        }

        if (result.failure) {
            UIAlertController *alert =
            [UIAlertController alertControllerWithTitle:@"No Connection"
                                                message:@"Make sure you are connected to the internet, then drag down on \"Now Playing\" to reload."
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* ok =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];

            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];

            [self.storeHouseRefreshControl finishingLoading];
            [spinner stopAnimating];
            return;
        }
    }];
}

- (void)loadPlaylistForShow:(Show *)show completion:(void (^) (WruwResult *))completion {
    NSDate *todaysDate = [[NSDate alloc] init];
    NSString *todaysDateString = [Show formatPathForDate:todaysDate];

    GetPlaylist *playlistService = [[GetPlaylist alloc]
                                    initWithShowName: show.title.asQuery
                                    date: todaysDateString];

    [playlistService requestWithCompletion:^(WruwResult *result) {
        completion(result);
    }];
}

- (void)updateCurrentPlaylist {
    [self loadPlaylistForShow:_currentShow completion:^(WruwResult *result) {
        if (result.success) {
            Playlist *playlist = (Playlist *)[result success];

            NSMutableArray *newSongs = [NSMutableArray arrayWithArray:[[playlist.songs reverseObjectEnumerator] allObjects]];
            [newSongs removeObjectsInArray:[NSMutableArray arrayWithArray:[[_archive reverseObjectEnumerator] allObjects]]];

            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                                   NSMakeRange(0,[newSongs count])];
            [_archive insertObjects:newSongs atIndexes:indexes];

            //[self getReleaseInfo];

            [self.storeHouseRefreshControl finishingLoading];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Now Playing"];
    [ARAnalytics event:@"Screen view"
        withProperties:@{ @"screen": @"Home View" }];
    
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
//    [self.tableView addSubview:spinner];

//    [spinner startAnimating];

    [showDescription setText:[NSString stringWithFormat:@""]];
    [showTitle setText:[NSString stringWithFormat:@""]];
    [hostLabel setText:[NSString stringWithFormat:@""]];
    showDescription.editable = NO;
    
    [self loadHomePage];

//    [self.tableView registerNib:[UINib nibWithNibName:@"SongTableViewCell" bundle:nil ] forCellReuseIdentifier:@"SongTableCellType"];
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
    
    [NSTimer scheduledTimerWithTimeInterval:60.0
                                     target:_tableView
                                   selector:@selector(getReleaseInfo)
                                   userInfo:nil
                                    repeats:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.streamPlay
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

#pragma mark - Navigation Bar delegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - Scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.storeHouseRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.storeHouseRefreshControl scrollViewDidEndDragging];
}

- (void)refreshTriggered {
    [self loadHomePage];
}

@end
