//
//  saveFavorite.m
//  WRUW
//
//  Created by Nick Jordan on 11/22/13.
//  Copyright (c) 2013 Nick Jordan. All rights reserved.
//

#import "saveFavorite.h"
#import "Song.h"
#import "getFilePath.h"

@implementation saveFavorite

-(void) saveFavorite:(Song *)currentSong {
    NSArray *favList = [[NSArray alloc] initWithObjects:currentSong, nil];
}

@end
