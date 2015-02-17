//
//  EmptyFavoritesView.h
//  WRUW
//
//  Created by Nick Jordan on 2/17/15.
//  Copyright (c) 2015 Nick Jordan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmptyFavoritesView : UIView

@property (weak, nonatomic) IBOutlet UILabel *infoText;

+(instancetype)emptySongs;
+(instancetype)emptyShows;

@end
