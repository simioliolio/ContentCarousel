//
//  CarouselContentView.m
//  ContentCarousel
//
//  Created by Simon Haycock on 07/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import "CarouselContentView.h"

@implementation CarouselContentView

-(instancetype)init {
    self = [super init];
    if (self) {
        _isReadyToView = NO;
    }
    return self;
}

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

-(void)stopContent {
    NSLog(@"stopContent called in superclass");
}


@end
