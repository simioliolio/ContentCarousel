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
    AVPlayer *player;
    AVPlayerView *playerView; // ??
    AVPlayerItem *playerItem;
    NSURL *url;
    
}

-(instancetype)initWithFrame:(NSRect)frameRect andPath:(NSString*)inVideoPath {
    self = [super initWithFrame:frameRect];
    if (self) {
        
        NSLog(@"initialise video view with path: %@", inVideoPath);
        url = [NSURL URLWithString:inVideoPath];
        
        
    }
    return self;
}

-(void)startContent {
//    [self addSubview:playerView];
//    [player play];
    NSLog(@"start content in video player");
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    NSString *tracksKey = @"tracks";
    static const NSString *ItemStatusContext;
    
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
         
          NSError *error;
         AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
         
         if (status == AVKeyValueStatusLoaded) {
             playerItem = [AVPlayerItem playerItemWithAsset:asset];
             // ensure that this is done before the playerItem is associated with the player
             [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
             [[NSNotificationCenter defaultCenter] addObserver:self
                                                      selector:@selector(playerItemDidReachEnd:)
                                                          name:AVPlayerItemDidPlayToEndTimeNotification
                                                        object:playerItem];
             player = [AVPlayer playerWithPlayerItem:playerItem];
             [playerView setPlayer:player];
             [player play];
         }
         else {
             // You should deal with the error appropriately.
             NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
//             [self tellDelegateContentHasFinished];
         }
          
     }];
     
    
}

-(void)playerItemDidReachEnd:(NSNotification*)notification {
    NSLog(@"reached the end");
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
