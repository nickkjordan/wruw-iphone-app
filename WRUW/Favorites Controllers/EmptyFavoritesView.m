//
//  EmptyFavoritesView.m
//  WRUW
//
//  Created by Nick Jordan on 2/17/15.
//  Copyright (c) 2015 Nick Jordan. All rights reserved.
//

#import "EmptyFavoritesView.h"
#import "FavoriteShowsTableViewController.h"
#import "FavoritesTableViewController.h"

typedef NS_ENUM(NSInteger, FavoritesStyle) {
    FavoritesStyleSongs,
    FavoritesStyleShows
};

@interface EmptyFavoritesView ()

    @property (assign, nonatomic) FavoritesStyle favoritesEnum;

@end

@implementation EmptyFavoritesView

@synthesize infoText, headerText;

-(id)initWithClass:(FavoritesStyle)style {
    self = [[[NSBundle mainBundle] loadNibNamed:@"EmptyFavoritesView" owner:self options:nil] objectAtIndex:0];
    _favoritesEnum = style;
    [self getText];
    return self;
}

+(instancetype)emptyShows {
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] initWithClass:FavoritesStyleShows];
    });
    return _sharedObject;
}

+(instancetype)emptySongs {
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] initWithClass:FavoritesStyleSongs];
    });
    return _sharedObject;
}

-(void)getText {
    switch (_favoritesEnum) {
        case 0:
            infoText.text = @"To add a song, tap a song to reveal its interactive buttons, then tap the heart icon";
            headerText.text = @"You don't have any Favorite Songs yet";
            break;
        case 1:
            infoText.text = @"To add a show, click on a show from the Programs guide below, then tap the heart icon";
            headerText.text = @"You don't have any Favorite Shows yet";
            break;
            
        default:
            break;
    }
}

@end
