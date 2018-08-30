#import "DisplayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "PlaylistsTableViewController.h"
#import <EventKit/EventKit.h>
#import "WRUWModule-Swift.h"
#import "ARAnalytics.h"

@interface DisplayViewController ()
{
    UITableView *tableView;
    UIActivityIndicatorView *spinner;
}
@end

@implementation DisplayViewController

@synthesize currentShow, currentShowTitle, currentShowHost, currentShowTime, currentShowInfo, favButton, showGenre, playlistsButton;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showPlaylistsSegue"]) {
        PlaylistsTableViewController *ptvc = [segue destinationViewController];
        
        // pass along showsParser
        
        [ptvc setCurrentShow:currentShow];
    }
}

- (void)adjustHeightOfInfoView {
    CGFloat fixedWidth = currentShowInfo.frame.size.width;
    currentShowInfo.frame = [self getSizeForText:currentShowInfo.text
                                        maxWidth:fixedWidth
                                            font:@"GillSans"
                                        fontSize:16];

    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 167 + currentShowInfo.frame.size.height)];
}

- (CGRect)getSizeForText:(NSString *)text
                maxWidth:(CGFloat)width
                    font:(NSString *)fontName
                fontSize:(float)fontSize {
    CGSize constraintSize;
    constraintSize.height = MAXFLOAT;
    constraintSize.width = width;

    UIFont *font = [UIFont fontWithName:fontName size:fontSize];
    NSDictionary *attributesDictionary =
        [NSDictionary dictionaryWithObjectsAndKeys:font,
         NSFontAttributeName,
         nil];
    
    CGRect frame = [text boundingRectWithSize:constraintSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributesDictionary
                                      context:nil];
    
    return frame;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    spinner = [[UIActivityIndicatorView alloc] init];
    spinner.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    spinner.color = [[ThemeManager current] wruwMainOrangeColor];
    [self.view addSubview:spinner];
    
    [spinner startAnimating];
    
    [self updateLabels];
    
    currentShowInfo.editable = NO;
    if (currentShowInfo.text.length == 0) {
        [spinner startAnimating];
    }

    GetPlaylists *playlistsService =
        [[GetPlaylists alloc] initWithShowName:currentShow.title.asQuery];

    [playlistsService requestWithCompletion:^(WruwResult *result) {
        self->currentShow.playlists = result.success;
        [self->spinner stopAnimating];
        [[self playlistsButton] setEnabled:YES];
    }];

    currentShowInfo.editable = YES;
    currentShowInfo.font = [UIFont fontWithName:@"GillSans" size:16];
    currentShowInfo.contentInset = UIEdgeInsetsMake(0,-4,0,0);
    currentShowInfo.editable = NO;
}

-(void)updateLabels {
    NSString *days = [currentShow.days componentsJoinedByString:@", "];

    NSString *hosts =
        [NSString stringWithFormat:@"hosted by %@", currentShow.hostsDisplay];

    NSString *time =
        [NSString stringWithFormat:@"on %@ from %@ to %@",
            days,
            currentShow.startTime.displayTime,
            currentShow.endTime.displayTime
        ];
    
    [currentShowTitle setText:currentShow.title];
    [currentShowHost setText:hosts];
    [currentShowTime setText:time];
    [currentShowInfo setText:currentShow.infoDescription];
    [showGenre setText:[currentShow.genre uppercaseString]];
    [self adjustHeightOfInfoView];
}

- (IBAction)favoritePush:(id)sender {
    BOOL saved = [FavoriteManager.instance saveFavoriteWithShow:currentShow];

    NSString *switchHeart;
    if (saved) {
        switchHeart = @"heart_24_red.png";
        [ARAnalytics event:@"Show Favorited"
            withProperties:@{ @"Show": currentShow.title}
         ];
    } else {
        switchHeart = @"heart_24.png";
    }
    
    [self buttonAnimation:favButton withImage:switchHeart];
}

-(void)buttonAnimation:(UIButton *)button withImage:(NSString *)imageName {
    
    UIImage *toImage = [UIImage imageNamed:imageName];
    
    [UIView transitionWithView:self.view
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        button.imageView.animationImages = [NSArray arrayWithObjects:toImage,nil];
                        [button.imageView startAnimating];
                        [button setImage:toImage forState:UIControlStateNormal];
                    } completion:nil];
}

@end
