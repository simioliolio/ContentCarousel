//
//  CarouselVideoView.h
//  ContentCarousel
//
//  Created by Simon Haycock on 07/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CarouselContentView.h"

@interface CarouselVideoView : CarouselContentView

/* returns nil if video cannot be loaded
 */
-(instancetype)initWithFrame:(NSRect)frameRect andPath:(NSString*)inImagePath;

-(void)startContent;

@end
