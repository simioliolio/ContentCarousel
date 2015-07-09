//
//  CarouselViewController.h
//  ContentCarousel
//
//  Created by Simon Haycock on 06/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FolderWatcher.h"
#import "CarouselContentView.h"

@interface CarouselViewController : NSViewController <FolderWatcherDelegate, CarouselContentDelegate>

-(instancetype)initWithFullScreenFrame:(CGRect)inFrame;

@end
