//
//  CarouselImageView.m
//  ContentCarousel
//
//  Created by Simon Haycock on 07/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import "CarouselImageView.h"

@implementation CarouselImageView {
    NSImageView *imageView;
    NSUInteger waitTime;
}

-(instancetype)initWithFrame:(NSRect)frameRect waitTime:(NSUInteger)inWaitTime andPath:(NSString*)inImagePath {
    self = [super initWithFrame:frameRect];
    if (self) {
        
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:inImagePath];
        if (!image) {
            return nil;
        }
        imageView = [[NSImageView alloc] initWithFrame:self.frame];
        [imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
        [imageView setImage:image];
        
        waitTime = inWaitTime;
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
//    [self addSubview:imageView];
}

-(void)startContent {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self addSubview:imageView];
    });
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0) , ^{
        [self tellDelegateContentHasFinished];
    });
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:waitTime target:self selector:@selector(tellDelegateContentHasFinished) userInfo:nil repeats:NO];
}

@end
