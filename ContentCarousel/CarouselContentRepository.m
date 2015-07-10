//
//  CarouselContentRepository.m
//  ContentCarousel
//
//  Created by Simon Haycock on 09/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import "CarouselContentRepository.h"
#import "FolderWatcher.h"

@implementation CarouselContentRepository {
    FolderWatcher *watcher;
}

-(instancetype)initWithWatchFolderPath:(NSString*)inPath andImageWaitTime:(Float32)inSeconds {
    self = [super init];
    if (self) {
        
        
        
    }
    return self;
}

-(void)updateWithFilenamesInFolder:(NSArray*)inStringArray {
    
}

@end
