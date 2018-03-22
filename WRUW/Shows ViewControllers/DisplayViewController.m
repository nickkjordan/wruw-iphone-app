#import "DisplayViewController.h"
#import "Playlist.h"
#import <AVFoundation/AVFoundation.h>
#import "PlaylistsTableViewController.h"
#import <EventKit/EventKit.h>
#import "WRUWModule-swift.h"
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

- (void)adjustHeightOfInfoView
{
    CGFloat fixedWidth = currentShowInfo.frame.size.width;
    currentShowInfo.frame = [self getSizeForText:currentShowInfo.text maxWidth:fixedWidth font:@"GillSans" fontSize:16];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, 167 + currentShowInfo.frame.size.height)];
}

- (CGRect)getSizeForText:(NSString *)text maxWidth:(CGFloat)width font:(NSString *)fontName fontSize:(float)fontSize {
    CGSize constraintSize;
    constraintSize.height = MAXFLOAT;
    constraintSize.width = width;
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:fontName size:fontSize], NSFontAttributeName,
                                          nil];
    
    CGRect frame = [text boundingRectWithSize:constraintSize
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:attributesDictionary
                                      context:nil];
    
    return frame;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
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
        currentShow.playlists = result.success;
        [spinner stopAnimating];
        [[self playlistsButton] setEnabled:YES];
    }];

    currentShowInfo.editable = YES;
    currentShowInfo.font = [UIFont fontWithName:@"GillSans" size:16];
    currentShowInfo.contentInset = UIEdgeInsetsMake(0,-4,0,0);
    currentShowInfo.editable = NO;
}

-(void)updateLabels {
    //curent show.startTime - currentShow.endTime
    NSString *days = [currentShow.days componentsJoinedByString:@", "];

    NSString *hosts = [currentShow.hosts componentsJoinedByString:@", "];
    
    [currentShowTitle setText:currentShow.title];
    [currentShowHost setText:[NSString stringWithFormat:@"hosted by %@", [hosts uppercaseString]]];
    [currentShowTime setText:[NSString stringWithFormat:@"on %@ from ", days]];
    [currentShowInfo setText:currentShow.infoDescription];
    [showGenre setText:[currentShow.genre uppercaseString]];
    [self adjustHeightOfInfoView];
}

//- (IBAction)calendarTap:(id)sender {
//    
//    EKEventStore *store = [[EKEventStore alloc] init];
//    
//    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//        // handle access here
//        
//        if (granted) {
//            
//            //
//            EKEventEditViewController* controller = [[EKEventEditViewController alloc] init];
//            controller.eventStore = store;
//            controller.editViewDelegate = self;
//            
//            //creating and modifying the event
//            EKEvent *showEvent = [EKEvent eventWithEventStore:store];
//            showEvent.title = currentShow.title;
//            
//            //find NSDates
//            NSDate *today = [NSDate date];
//            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//            [gregorian setLocale:[NSLocale currentLocale]];
//            
//            NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
//            NSDateComponents *components = [[NSDateComponents alloc] init];
//            [components setWeekday:5]; //5 = Thursday
//            
//            NSLog(@"%d  ~=  %d",components.weekday, nowComponents.weekday);
//            if (components.weekday < nowComponents.weekday) {
//                [components setWeek: [nowComponents week] + 1]; //Next week
//            } else {
//                [components setWeek:nowComponents.week];
//            }
//            
//            NSString *meridian = [[currentShow.time componentsSeparatedByString:@" "] objectAtIndex:2];
//            NSString *startString =[[currentShow.time componentsSeparatedByString:@" "] objectAtIndex:1];
//            int start = startString.intValue;
//            
//            if ([meridian isEqualToString:@"AM"]) {
//                [components setHour:start]; //8a.m.
//            } else {
//                [components setHour:start+12];
//            }
//            
//            NSLog(@"%d", components.hour);
//            [components setMinute:0];
//            [components setSecond:0];
//            
//            NSDate *startDate = [gregorian dateFromComponents:components];
//            showEvent.startDate = startDate;
//            
//            NSString *endString =[[currentShow.time componentsSeparatedByString:@" "] objectAtIndex:4];
//            
//            // adding weekly recurrence
//            EKRecurrenceRule *recurrence = [[EKRecurrenceRule alloc]
//                                            initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
//                                            interval:1
//                                            end:nil];
//            [showEvent addRecurrenceRule:recurrence];
//            
//            // Adding the event to the View Controller and displaying it
//            controller.event = showEvent;
//            [self presentViewController:controller animated:YES completion:nil];
//            
//        } else {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event"
//                                                            message:@"To create a Calendar event for this show, you must allow access!"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles: nil];
//            [alert show];
//        }
//    }];
//
//}

-(NSString *) getFilePath {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [[pathArray objectAtIndex:0] stringByAppendingPathComponent:@"favoriteShows.plist"];
}

-(void) saveFavorite:(Show *)show {
    
    NSString *path = [self getFilePath];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    
    if (fileExists) {
        NSData *favoritesData = [[NSData alloc] initWithContentsOfFile:path];
        // Get current content.
        NSMutableArray *content = [NSKeyedUnarchiver unarchiveObjectWithData:favoritesData];
        // Make a mutable copy.
        //        NSMutableArray *newContent = [oldContent mutableCopy];
        
        if ([content containsObject:show]) {
            
            [content removeObject:show];
        } else {
            // Add new stuff.
            [content insertObject:show atIndex:0];
        }
        
        // Now, write the plist:
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:content];
        
        [data writeToFile:path atomically:YES];
    } else {
        NSMutableArray *newFavorite = [[NSMutableArray alloc] initWithObjects:show, nil];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:newFavorite];
        
        [data writeToFile:path atomically:YES];
    }
}

- (IBAction)favoritePush:(id)sender {
    [self saveFavorite:currentShow];
    
    NSData *testHeart  = UIImagePNGRepresentation([UIImage imageNamed:@"heart_24.png"]);
    NSData *currentHeart = UIImagePNGRepresentation(favButton.currentImage);
    
    NSString *switchHeart;
    if ([testHeart isEqualToData:currentHeart]){
        switchHeart = @"heart_24_red.png";
        [ARAnalytics event:@"Show Favorited" withProperties:@{
                                                              @"Show": currentShow.title
                                                              }];
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
