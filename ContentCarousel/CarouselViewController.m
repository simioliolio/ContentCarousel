//
//  CarouselViewController.m
//  ContentCarousel
//
//  Created by Simon Haycock on 06/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import "CarouselViewController.h"
#import "FolderWatcher.h"
#import "CarouselImageView.h"
#import "CarouselVideoView.h"

@interface CarouselViewController ()

@property (strong) NSString *watchPath;

@end

@implementation CarouselViewController {
    CGRect proposedFrame;
    FolderWatcher *folderWatcher;
    
    /* array dictates the order that content is loaded. when folder
     watcher is updated, the contents are compared, and adjusted
     accordingly, on the media presentation queue.
     */
    NSMutableArray *filenamesForContent;
    
    /* index for choosing next filename string to load
     */
    NSUInteger selectedStringIndex;
    
    /* thread for ensuring filenamesForContent is not modified whilst
     * being read
     */
    dispatch_queue_t presentationQueue;
    
    NSUInteger waitTimeForImages; // temp until xml is implemented
    
    BOOL isInitialising; // used whilst doing first sync (and selectStringIndex should come out as being 0)
    
}

-(instancetype)initWithWatchPath:(NSString*)inPath andFullScreenFrame:(CGRect)inFrame {
    self = [super init];
    if (self) {
        
        isInitialising = YES;
        
        presentationQueue = dispatch_queue_create("presentationQueue", NULL);
        
        // look in an xml, and get wait time and watch folder path from there?
        waitTimeForImages = 3;
        
        self.watchPath = inPath;
        proposedFrame = inFrame;
        filenamesForContent = [[NSMutableArray alloc] init];
        selectedStringIndex = 0;
        
        folderWatcher = [[FolderWatcher alloc] initWithPath:self.watchPath];
        [folderWatcher setDelegate:self]; // delegate method called straight away for sync
//        selectedStringIndex = 0; // check
        
    }
    return self;
}

-(void)loadView {
    self.view = [[NSView alloc] initWithFrame:proposedFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSLog(@"viewDidLoad, self.view.frame = %@", NSStringFromRect(self.view.frame));
    dispatch_async(presentationQueue, ^{
        [self presentContentBasedOnSelectedStringIndex];
    });
    
    
}

-(void)incrementSelectedStringIndex {
    selectedStringIndex++;
    // wrap
    if (selectedStringIndex >= [filenamesForContent count]) {
        selectedStringIndex = 0;
    }
}

-(void)presentContentBasedOnSelectedStringIndex { // based on selectedStringIndex
    
    NSUInteger numberOfLoops = 0;
    BOOL contentSuccessfullyLoaded = NO;
    
    CarouselContentView *contentView;
    while (!contentSuccessfullyLoaded) {
        if ([filenamesForContent count] > selectedStringIndex) {
            NSString *relativeFilenameString = [filenamesForContent objectAtIndex:selectedStringIndex];
            NSString *absoluteFilenameString = [NSString stringWithFormat:@"%@/%@", self.watchPath, relativeFilenameString];
            CFStringRef fileExtension = (__bridge CFStringRef) [absoluteFilenameString pathExtension];
            CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
            
            if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
                // image
                CarouselImageView *imageContentView = [[CarouselImageView alloc] initWithFrame:self.view.frame waitTime:waitTimeForImages andPath:absoluteFilenameString];
                if (imageContentView) {
                    contentView = imageContentView; //
                    contentSuccessfullyLoaded = YES; // tap out
                } else {
                    [self incrementSelectedStringIndex];
                }
            }
            else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) {
                // movie
//                NSLog(@"movie class not written yet");
//                [self incrementSelectedStringIndex];
                
                CarouselVideoView *videoContentView = [[CarouselVideoView alloc] initWithFrame:self.view.frame andPath:absoluteFilenameString];
                if (videoContentView) {
                    contentView = videoContentView; //
                    contentSuccessfullyLoaded = YES;
                } else {
                    [self incrementSelectedStringIndex];
                }
            } else {
                // something else
                NSLog(@"file is neither picture of video");
                [self incrementSelectedStringIndex];
            }
            CFRelease(fileUTI);
        }
        
        numberOfLoops++;
        if (numberOfLoops > 1000) {
            NSLog(@"1000 files in the watch folder which are not pictures or videos. are you sure the watch folder is correct? application is now broken");
            return;
        }
    }
    
    // remove current subviews
    NSArray *subviews = [self.view subviews];
    for (NSView *view in subviews) {
        [view removeFromSuperview];
    }
    
    [contentView setDelegate:self];
    [self.view addSubview:contentView];
    [contentView startContent];
    
    
}

// CarouselContentDelegate
-(void)contentDidFinish:(id)content {
    NSLog(@"%s", __FUNCTION__);
    dispatch_async(presentationQueue, ^{
        [self incrementSelectedStringIndex];
        [self presentContentBasedOnSelectedStringIndex];
    });
    
}

-(void)syncroniseWithFilenameArray:(NSArray*)inArray {
    
    // keep track of the currently selected place in the array by adding a bookmark. this will move around as objects are added, deleted, and reordered. This will be removed later.
    NSString *bookmark;
    if ([filenamesForContent count] > selectedStringIndex) {
        NSString *stringAtSelectedIndex = [filenamesForContent objectAtIndex:selectedStringIndex]; // must be ordered the same, so bookmark is based around neighbouring string
        bookmark = [NSString stringWithString:stringAtSelectedIndex];
    } else {
        bookmark = @"bookmark";
    }
    
    [filenamesForContent insertObject:bookmark atIndex:selectedStringIndex];
    
    // if a string is in inArray, but not in own array, add it.
    for (NSString *string in inArray) {
        if (![filenamesForContent containsObject:string]) {
            [filenamesForContent addObject:string];
        }
    }
    
    // if a string is in own array, but is not in inArray, add to another array, then use to remove from own array.
    NSMutableArray *removalArray = [[NSMutableArray alloc] init];
    for (NSString *string in filenamesForContent) {
        if ( ([inArray containsObject:string] == NO) && (string != bookmark)) {
            [removalArray addObject:string];
        }
    }
    for (NSString *string in removalArray) {
        [filenamesForContent removeObject:string];
    }
    
    // at this point, each array should contain the same strings. own array also contains the bookmark
    if ([inArray count] == ([filenamesForContent count] - 1)) {
        
        // order into case insensitve alphabetical order
        NSArray *sortedArray = [filenamesForContent sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        filenamesForContent = nil;
        filenamesForContent = [[NSMutableArray alloc] initWithArray:sortedArray copyItems:NO];
        // find bookmark
        NSUInteger bookmarkPosition = [filenamesForContent indexOfObject:bookmark];
        
        // set selected index to be bookmark position
        if (isInitialising) {
            selectedStringIndex = 0;
            isInitialising = NO;
        } else {
            selectedStringIndex = bookmarkPosition;
        }
        
        // remove bookmark
        [filenamesForContent removeObjectAtIndex:bookmarkPosition];
        
        // the next filename to be used is the one after stringAtSelectedIndex (defined above). if stringAtSelected is removed, the filename after is assumed to have already been shown. this can be fixed.
        
    } else {
        NSLog(@"unexpected array size");
    }
    
    NSLog(@"syncroniseWithFilenameArray; filenamesForContent: \n%@", filenamesForContent);
}

// delegate method
-(void)filenamesUpdatedInFolderWatcher {
    NSArray *localFileNamesInWatchFolder = folderWatcher.filenamesInWatchFolder;
    dispatch_async(presentationQueue, ^{
        [self syncroniseWithFilenameArray:folderWatcher.filenamesInWatchFolder];
    });
    
}

@end














