//
//  AppDelegate.m
//  WRUW
//
//  Created by Nick Jordan on 9/7/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "AppDelegate.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set AudioSession
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    // Title View
    [[UINavigationBar appearance]
     setTitleTextAttributes: @{ NSForegroundColorAttributeName:[UIColor blackColor],
                               NSFontAttributeName:[UIFont fontWithName:@"Futura-Medium" size:24.0],
                               } ];
    
    // Change Navigation Bar buttons font and color
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes: @{ NSForegroundColorAttributeName:[UIColor blackColor],                                                                                                       NSFontAttributeName: [UIFont fontWithName:@"GillSans-Light" size:14.0f] }
     forState:UIControlStateNormal];
    
    // Segmented Control color
    [[UISegmentedControl appearance]
     setTitleTextAttributes:@{ NSFontAttributeName:[UIFont fontWithName:@"Futura" size:14.0f]
                                                              } forState:UIControlStateNormal];

    /* Pick any one of them */
    // 1. Overriding the output audio route
    //UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    //AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    
    // 2. Changing the default output audio route
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    // Override point for customization after application launch.
    return YES;
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
