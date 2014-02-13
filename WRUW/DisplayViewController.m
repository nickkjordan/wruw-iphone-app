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
#import "PlaylistsTableViewController.h"
#import <EventKit/EventKit.h>

@interface DisplayViewController () <AVAudioPlayerDelegate>
{
    AVAudioPlayer *audioPlayer;
    UITableView *tableView;
    TFHpple *showsParser;
}
@end

@implementation DisplayViewController

@synthesize currentShow, currentShowTitle, currentShowHost, currentShowTime, currentShowInfo, favButton;

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showPlaylistsSegue"]) {
        PlaylistsTableViewController *ptvc = [segue destinationViewController];
        
        // pass along showsParser
        
        [ptvc setCurrentShow:currentShow];
        [ptvc setCurrentParser:showsParser];
    }
}

-(void)loadInfo {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentShowInfo setText:@""];
    });
    
    // 1
    NSURL *showsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.wruw.org/guide/%@",currentShow.url]];
    NSData *showsHtmlData = [NSData dataWithContentsOfURL:showsUrl];
    
    // 2
    showsParser = [TFHpple hppleWithHTMLData:showsHtmlData];
    
    NSString *infoXpathQueryString = @"/html/body/table[2]/tr[1]/td/table/tr[2]/td[2]/p[2]";
    NSArray *infoNode = [showsParser searchWithXPathQuery:infoXpathQueryString];

    NSString *showInfo = [[infoNode[0] firstChild] content];
    showInfo = [showInfo stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    showInfo = [showInfo stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [currentShowInfo setText:[showInfo
                                  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        [NSTimer scheduledTimerWithTimeInterval:.06 target:self selector:@selector(adjustHeightOfInfoView) userInfo:nil repeats:NO];
    });
    
    
}

- (void)adjustHeightOfInfoView
{
    self.textViewHeightConstraint.constant = currentShowInfo.contentSize.height;
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
    
    dispatch_queue_t myQueue = dispatch_queue_create("org.wruw.app", NULL);
    
    currentShowInfo.editable = NO;
    dispatch_async(myQueue, ^{ [self loadInfo]; });
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)calendarTap:(id)sender {
    
    EKEventStore *store = [[EKEventStore alloc] init];
    
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        // handle access here
        
        if (granted) {
            
            //
            EKEventEditViewController* controller = [[EKEventEditViewController alloc] init];
            controller.eventStore = store;
            controller.editViewDelegate = self;
            
            //creating and modifying the event
            EKEvent *showEvent = [EKEvent eventWithEventStore:store];
            showEvent.title = currentShow.title;
            
            //find NSDates
            NSDate *today = [NSDate date];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            [gregorian setLocale:[NSLocale currentLocale]];
            
            NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setWeekday:5]; //5 = Thursday
            
            NSLog(@"%d  ~=  %d",components.weekday, nowComponents.weekday);
            if (components.weekday < nowComponents.weekday) {
                [components setWeek: [nowComponents week] + 1]; //Next week
            } else {
                [components setWeek:nowComponents.week];
            }
            
            NSString *meridian = [[currentShow.time componentsSeparatedByString:@" "] objectAtIndex:2];
            NSString *startString =[[currentShow.time componentsSeparatedByString:@" "] objectAtIndex:1];
            int start = startString.intValue;
            
            if ([meridian isEqualToString:@"AM"]) {
                [components setHour:start]; //8a.m.
            } else {
                [components setHour:start+12];
            }
            
            NSLog(@"%d", components.hour);
            [components setMinute:0];
            [components setSecond:0];
            
            NSDate *startDate = [gregorian dateFromComponents:components];
            showEvent.startDate = startDate;
            
            NSString *endString =[[currentShow.time componentsSeparatedByString:@" "] objectAtIndex:4];
            
            // adding weekly recurrence
            EKRecurrenceRule *recurrence = [[EKRecurrenceRule alloc]
                                            initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
                                            interval:1
                                            end:nil];
            [showEvent addRecurrenceRule:recurrence];
            
            // Adding the event to the View Controller and displaying it
            controller.event = showEvent;
            [self presentViewController:controller animated:YES completion:nil];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event"
                                                            message:@"To create a Calendar event for this show, you must allow access!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }];

}

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
    
    UIImage *testHeart  = [UIImage imageNamed:@"heart_24.png"];
    UIImage *currentHeart = favButton.currentImage;
    
    NSString *switchHeart = ([testHeart isEqual:currentHeart]) ? (@"heart_24_red.png") : (@"heart_24.png");
    
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