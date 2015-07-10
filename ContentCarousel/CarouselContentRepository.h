//
//  CarouselContentRepository.h
//  ContentCarousel
//
//  Created by Simon Haycock on 09/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarouselContentView.h"

// delegate protocol


@interface CarouselContentRepository : NSObject

@property (readonly) NSString *watchFolderPath;
@property (readonly) Float32 imageWaitTime;
@property (readonly) NSMutableArray *contentArray;

-(instancetype)initWithWatchFolderPath:(NSString*)inPath andImageWaitTime:(Float32)inSeconds;

-(void)updateWithFilenamesInFolder:(NSArray*)inStringArray;


@end
