//
//  HomeViewController.m
//  WRUW
//
//  Created by Nick Jordan on 9/10/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "HomeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HomeViewController () <AVAudioPlayerDelegate>
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@end

@implementation HomeViewController

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
	// Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)streamPlay:(id)sender {
    NSString *urlAddress = @"http://www.wruw.org/listen/stream.php?stream=live128";
    NSURL *urlStream = [NSURL URLWithString:urlAddress];
    AVPlayer *musicPlayer = [AVPlayer playerWithURL:urlStream];
    [musicPlayer play];
}


@end
