//
//  AppDelegate.m
//  WRUW
//
//  Created by Nick Jordan on 9/7/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "AppDelegate.h"
#import <ARAnalytics/ARAnalytics.h>
#import <ARAnalytics/ARDSL.h>
#import <Keys/WRUWFMKeys.h>
#import "WRUWModule-Swift.h"
#import "SongTableViewCell.h"
#import "HomeViewController.h"
#import "GroupedProgramsTableViewController.h"
//#import "SDStatusBarManager.h"

@implementation AppDelegate

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
    // Internal error reporting
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set AudioSession
    NSError *sessionError = nil;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];

    [session setActive:YES error:nil];
    if (![session setCategory:AVAudioSessionCategoryPlayback
                  withOptions:AVAudioSessionCategoryOptionMixWithOthers
                        error:&sessionError]) {
        // handle error
    }
    
    // Title View
    NSString *font = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.2) ? @"GillSans-SemiBold" : @"GillSans";
    [[UINavigationBar appearance]
     setTitleTextAttributes: @{ NSForegroundColorAttributeName:[UIColor blackColor],
                               NSFontAttributeName:[UIFont fontWithName:font size:16.0],
                               }];
    
    [[UINavigationBar appearance] setTintColor:[[ThemeManager current] wruwMainOrangeColor]];
    
    // Change Navigation Bar buttons font and color
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
        setTitleTextAttributes: @{
            NSForegroundColorAttributeName:[[ThemeManager current] wruwMainOrangeColor],
            NSFontAttributeName: [UIFont fontWithName:@"GillSans" size:14.0f]
        }
        forState:UIControlStateNormal];

    // Segmented Control color
    [[UISegmentedControl appearance]
        setTitleTextAttributes: @{
            NSFontAttributeName:[UIFont fontWithName:@"Futura" size:14.0f]
        }
           forState: UIControlStateNormal];

    [[UITabBar appearance] setTintColor:[[ThemeManager current] wruwMainOrangeColor]];
        
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    //[[SDStatusBarManager sharedInstance] enableOverrides];
    
    [self setupAnalytics];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    return YES;
}

- (void)setupAnalytics {
    WRUWFMKeys *keys = [[WRUWFMKeys alloc] init];

    [ARAnalytics setupWithAnalytics:@{
            ARMixpanelToken : keys.mixpanelToken
        }
                      configuration:@{
                            ARAnalyticsTrackedScreens : @[ @{
                                        ARAnalyticsClass: UIViewController.class,
                                        ARAnalyticsDetails: @[ @{
                                                ARAnalyticsPageNameKeyPath: @"title",
                                                ARAnalyticsShouldFire: ^BOOL(UIViewController *controller, NSArray *parameters) {
                                                    if ([controller isKindOfClass:ArchiveViewController.class] ||
                                                        [controller isKindOfClass:HomeViewController.class] ||
                                                        [controller isKindOfClass:GroupedProgramsTableViewController.class]) {
                                                        return NO;
                                                    }
                                                    return controller.title != nil;
                                                },
                                                }],
                                        },
                                        @{
                                        ARAnalyticsClass: ArchiveViewController.class,
                                        ARAnalyticsDetails: @[ @{
                                            ARAnalyticsPageName: @"Archive View",
                                            }]},
                                        @{
                                        ARAnalyticsClass: HomeViewController.class,
                                        ARAnalyticsDetails: @[ @{
                                            ARAnalyticsPageName: @"Home View",
                                            }]},
                                        @{
                                        ARAnalyticsClass: GroupedProgramsTableViewController.class,
                                        ARAnalyticsDetails: @[ @{
                                            ARAnalyticsPageName: @"Programs Selector View",
                                            }]},
                                    ],
                            ARAnalyticsTrackedEvents : @[ @{
                                        ARAnalyticsClass: StreamPlayView.class,
                                        ARAnalyticsDetails: @[ @{
                                                ARAnalyticsEventName: @"Stream Button Pressed",
                                                ARAnalyticsSelectorName: NSStringFromSelector(@selector(didTapPlayer)),
                                                }]
                                        },
                                                          @{
                                        ARAnalyticsClass: SongTableViewCell.class,
                                        ARAnalyticsDetails: @[ @{
                                                ARAnalyticsEventName: @"Favorited Song",
                                                ARAnalyticsSelectorName: NSStringFromSelector(@selector(favoritePush:))
                                            },
                                            @{
                                                ARAnalyticsEventName: @"Searched Song",
                                                ARAnalyticsSelectorName: NSStringFromSelector(@selector(searchSong:))
                                            },
                                            @{
                                                ARAnalyticsEventName: @"Pushed Facebook",
                                                ARAnalyticsSelectorName: NSStringFromSelector(@selector(composeFBPost:))
                                            },
                                            @{
                                                ARAnalyticsEventName: @"Pushed Twitter",
                                                ARAnalyticsSelectorName: NSStringFromSelector(@selector(composeTwitterPost:))
                                            }]
                                        }]
    }];
}

@end
