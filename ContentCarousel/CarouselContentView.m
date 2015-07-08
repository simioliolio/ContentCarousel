//
//  CarouselContentView.m
//  ContentCarousel
//
//  Created by Simon Haycock on 07/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import "CarouselContentView.h"

@implementation CarouselContentView

/*
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
 */


-(void)tellDelegateContentHasFinished {
//    NSLog(@"tellDelegateContentHasFinished");
    if (_delegate) {
        [_delegate contentDidFinish:self];
    }
}

-(void)startContent {
    NSLog(@"startContent called in superclass");
}


@end
