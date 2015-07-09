//
//  AppDelegate.m
//  ContentCarousel
//
//  Created by Simon Haycock on 06/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import "AppDelegate.h"
#import "CarouselViewController.h"

@interface AppDelegate ()

//@property (weak) IBOutlet NSWindow *window;
@property (readwrite) IBOutlet NSWindow *window;
@property (readwrite) CarouselViewController *viewController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [self.window setDelegate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
//    NSLog(@"frameRect = %@", NSStringFromRect(self.window.frame));
    static BOOL shouldGoFullScreen = YES;
    if (shouldGoFullScreen) {
        if (!([self.window styleMask] & NSFullScreenWindowMask))
            [self.window toggleFullScreen:nil];
        shouldGoFullScreen = NO;
    }
    
//    NSLog(@"frameRect = %@", NSStringFromRect(self.window.frame));
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setupCarouselAfterEnsuringFullScreen];        
    });
    
    
}

-(void)setupCarouselAfterEnsuringFullScreen {
    
    if (!([self.window styleMask] & NSFullScreenWindowMask)) {
        NSLog(@"view is not full screen. not continuing with setup");
        return;
    }
    
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES );
//    NSString* desktopPath = [paths objectAtIndex:0];
    self.viewController = [[CarouselViewController alloc] initWithFullScreenFrame:self.window.frame];
    [self.window setContentView:self.viewController.view];
    
}

@end
