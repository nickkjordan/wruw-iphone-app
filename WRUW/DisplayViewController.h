//
//  DisplayViewController.h
//  WRUW
//
//  Created by Nick Jordan on 11/15/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Show.h"

@interface DisplayViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *currentShowTitle;

@property (weak, nonatomic) IBOutlet UILabel *currentShowHost;

@property (weak, nonatomic) IBOutlet UILabel *currentShowTime;

@property (strong, nonatomic) Show *currentShow;

@end
