#import "HomeViewController.h"
#import "WRUWModule-Swift.h"
#import "DisplayViewController.h"
#import "ARAnalytics.h"

@interface HomeViewController () <AVAudioPlayerDelegate>
{
    NSMutableArray *_archive;
    UIRefreshControl *_refreshControl;
}
@property (nonatomic, strong) ArrayDataSource *songsArrayDataSource;
@property (nonatomic, strong) Show *currentShow;
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
        [self->_refreshControl endRefreshing];

        if (result.success) {
            Show *newShow = (Show *)[result success];

            self.moreInfoButton.enabled = YES;
    
            if (![newShow isEqual:self->_currentShow]) {
                self->_currentShow = newShow;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->showTitle setText:self->_currentShow.title];
                    [self->hostLabel setText:self->_currentShow.hostsDisplay];
                });
    
                // remove current playlist
                NSDate *todaysDate = [[NSDate alloc] init];
                NSString *dateString = [Show formatPathFor:todaysDate];
                [self.tableView loadWithShow:newShow.title.asQuery
                                        date:dateString];
                
                self->_archive = [NSMutableArray array];
            } else {
                [self.tableView updateCurrentPlaylist];
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

            return;
        }
    }];
}

- (void)viewDidLoad {
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
    
    [showDescription setText:[NSString stringWithFormat:@""]];
    [showTitle setText:[NSString stringWithFormat:@""]];
    [hostLabel setText:[NSString stringWithFormat:@""]];
    showDescription.editable = NO;
    
    [self loadHomePage];

    [self.tableView setSeparatorColor:[UIColor clearColor]];
    _tableView.reversed = true;
    _tableView.scrollViewDelegate = self;

    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [[ThemeManager current] wruwMainOrangeColor];
    [_refreshControl addTarget:self
                        action:@selector(loadHomePage)
              forControlEvents:UIControlEventPrimaryActionTriggered];

    _tableView.refreshControl = _refreshControl;

    // Set navigation bar
    self.navigationBar.delegate = self;
    
    self.streamPlay = [[StreamPlayView alloc] initWithFrame:CGRectMake(0, 0, 140, 150)];
    [self.showView addSubview:self.streamPlay];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0
                                     target:self
                                   selector:@selector(loadHomePage)
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

@end
