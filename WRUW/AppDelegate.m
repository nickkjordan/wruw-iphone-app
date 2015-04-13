//
//  AppDelegate.m
//  WRUW
//
//  Created by Nick Jordan on 9/7/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "AppDelegate.h"
#import "UIColor+WruwColors.h"
#import <ARAnalytics/ARAnalytics.h>
#import <ARAnalytics/ARDSL.h>
#import <Keys/WRUWKeys.h>
#import "WRUWModule-Swift.h"
#import "SongTableViewCell.h"
#import "ArchiveTableViewController.h"
#import "HomeViewController.h"
#import "GroupedProgramsTableViewController.h"
#import "SDStatusBarManager.h"

@implementation AppDelegate

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
    [[UINavigationBar appearance]
     setTitleTextAttributes: @{ NSForegroundColorAttributeName:[UIColor blackColor],
                               NSFontAttributeName:[UIFont fontWithName:@"GillSans-SemiBold" size:16.0],
                               }];
    
    [[UINavigationBar appearance] setTintColor:[UIColor wruwColor]];
    
    // Change Navigation Bar buttons font and color
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes: @{ NSForegroundColorAttributeName:[UIColor wruwColor],                                                                                                       NSFontAttributeName: [UIFont fontWithName:@"GillSans" size:14.0f] }
     forState:UIControlStateNormal];
    
    // Segmented Control color
    [[UISegmentedControl appearance]
     setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Futura" size:14.0f]
                                                              } forState:UIControlStateNormal];
    


    [[UITabBar appearance] setTintColor:[UIColor wruwColor]];
        
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[SDStatusBarManager sharedInstance] enableOverrides];
    
    [self setupAnalytics];
    
    return YES;
}

- (void)setupAnalytics
{
    WRUWKeys *keys = [[WRUWKeys alloc] init];
    [ARAnalytics setupWithAnalytics:@{
            ARMixpanelToken : keys.mixpanelToken
        }
                      configuration:@{
                            ARAnalyticsTrackedScreens : @[ @{
                                        ARAnalyticsClass: UIViewController.class,
                                        ARAnalyticsDetails: @[ @{
                                                ARAnalyticsPageNameKeyPath: @"title",
                                                ARAnalyticsShouldFire: ^BOOL(UIViewController *controller, NSArray *parameters) {
                                                    if ([controller isKindOfClass:ArchiveTableViewController.class] ||
                                                        [controller isKindOfClass:HomeViewController.class] ||
                                                        [controller isKindOfClass:GroupedProgramsTableViewController.class]) {
                                                        return NO;
                                                    }
                                                    return controller.title != nil;
                                                },
                                                }],
                                        },
                                        @{
                                        ARAnalyticsClass: ArchiveTableViewController.class,
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
                                                ARAnalyticsSelectorName: NSStringFromSelector(@selector(statusChanged)),
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
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
