//
//  HomeViewController.h
//  WRUW
//
//  Created by Nick Jordan on 9/10/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TFHpple.h"

@interface HomeViewController : UIViewController
- (IBAction)streamPlay:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *currentShowTitle;
@property (weak, nonatomic) IBOutlet UITextView *currentShowDescription;
@end
