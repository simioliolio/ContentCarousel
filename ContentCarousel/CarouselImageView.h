//
//  CarouselImageView.h
//  ContentCarousel
//
//  Created by Simon Haycock on 07/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CarouselContentView.h"

@interface CarouselImageView : CarouselContentView

/* returns nil if image cannot be loaded
 */
-(instancetype)initWithFrame:(NSRect)frameRect waitTime:(NSUInteger)inWaitTime andPath:(NSString*)inImagePath;

@end



