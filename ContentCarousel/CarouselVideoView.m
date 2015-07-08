//
//  CarouselVideoView.m
//  ContentCarousel
//
//  Created by Simon Haycock on 07/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import "CarouselVideoView.h"
@import AVFoundation;
@import AVKit;

@implementation CarouselVideoView {
    AVURLAsset *asset;
    AVPlayer *player;
    AVPlayerView *playerView; // ??
    AVPlayerItem *playerItem;
    NSURL *url;
    
}

-(instancetype)initWithFrame:(NSRect)frameRect andPath:(NSString*)inVideoPath {
    self = [super initWithFrame:frameRect];
    if (self) {
        
        NSLog(@"initialise video view with path: %@", inVideoPath);
        url = [[NSURL alloc] initFileURLWithPath:inVideoPath];
        
        
    }
    return self;
}

-(void)startContent {
//    [self addSubview:playerView];
//    [player play];
    
    asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    NSString *tracksKey = @"tracks";
    
//    NSLog(@"about to start loading tracks for %@", url);
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
         
         dispatch_async(dispatch_get_main_queue(), ^{
             NSError *error;
             AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
             
             if (status == AVKeyValueStatusLoaded) {
                 playerItem = [AVPlayerItem playerItemWithAsset:asset];
                 // ensure that this is done before the playerItem is associated with the player
                 //             [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
                 [[NSNotificationCenter defaultCenter] addObserver:self
                                                          selector:@selector(playerItemDidReachEnd:)
                                                              name:AVPlayerItemDidPlayToEndTimeNotification
                                                            object:playerItem];
                 player = [AVPlayer playerWithPlayerItem:playerItem];
                 playerView = [[AVPlayerView alloc] initWithFrame:self.frame];
                 [playerView setControlsStyle:AVPlayerViewControlsStyleNone];
                 [playerView setPlayer:player];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self addSubview:playerView];
                 });
                 
                 [player play];
                 NSLog(@"play called");
             }
             else {
                 // You should deal with the error appropriately.
                 NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                 [self tellDelegateContentHasFinished];
             }
         });
//         NSLog(@"completion handler called!");
//         static const NSString *ItemStatusContext;
         
         
         
         
         
         
     }];

    
}

-(void)playerItemDidReachEnd:(NSNotification*)notification {
//    NSLog(@"reached the end");
    [self tellDelegateContentHasFinished];
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
