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
    
    FolderWatcher *folderWatcher; // XML
    NSUInteger waitTimeForImages; // XML
    
    /* array dictates the order that content is loaded. when folder
     * watcher is updated, the contents are updated on the presentation queue.
     */
    NSArray *filenamesForContent;
    
    /* represents current content position
     */
    NSUInteger selectedStringIndex;
    
    /* queue for ensuring filenamesForContent is not modified whilst
     * being read
     */
    dispatch_queue_t presentationQueue;
    
    /* if folder is empty, there is nothing to display. this bool allows folder
     * sync to trigger the loading of content
     */
    BOOL isRunning;
    
    NSFileManager *fm;
    
    
    CarouselContentView *contentView;
}

-(instancetype)initWithFullScreenFrame:(CGRect)inFrame {
    self = [super init];
    if (self) {
        
        presentationQueue = dispatch_queue_create("presentationQueue", NULL);
        isRunning = YES;
        fm = [NSFileManager defaultManager];
        
        NSString *fallbackWatchFolderPath = @"/Users/Shared/ContentCarousel";
        NSUInteger fallbackWaitTimeForImages = 10;
        
        NSString *pathOfPlist = [[NSBundle mainBundle] pathForResource:@"ContentCarouselSettings" ofType:@"plist"];
        NSLog(@"path of plist = %@", pathOfPlist);
        NSLog(@"expected keys: 'imageWaitTime' (Number). 'watchFolderPath' (String)");
        if ([fm fileExistsAtPath:pathOfPlist]) {
            NSLog(@"plist found");
            NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:pathOfPlist];
//            NSLog(@"plistDictionary: %@", plistDictionary);
            NSString *watchPath = [plistDictionary valueForKey:@"watchFolderPath"];
            if (watchPath) {
                self.watchPath = watchPath;
            } else {
                NSLog(@"value in plist for 'watchFolderPath' not found. setting as '/Users/Shared/ContentCarousel'");
                self.watchPath = fallbackWatchFolderPath;
            }
            NSNumber *number = [plistDictionary valueForKey:@"imageWaitTime"];
            if (number) {
                waitTimeForImages = [number integerValue];
            } else {
                NSLog(@"value in plist for 'imageWaitTime' not found. setting as 10");
                waitTimeForImages = fallbackWaitTimeForImages;
            }
        } else {
            NSLog(@"no plist found. using 10 second wait time and fallback watch folder path '/Users/Shared/ContentCarousel'");
            waitTimeForImages = fallbackWaitTimeForImages;
            self.watchPath = fallbackWatchFolderPath;
        }
        NSLog(@"watchFolderPath = %@", self.watchPath);
        NSLog(@"imageWaitTime = %li", waitTimeForImages);
        
        // ! use auto-layout, not an explicit frame !
        proposedFrame = inFrame;
        
        folderWatcher = [[FolderWatcher alloc] initWithPath:self.watchPath];
        [folderWatcher setDelegate:self];
        
        // initial sync
        filenamesForContent = [[NSMutableArray alloc] initWithArray:folderWatcher.filenamesInWatchFolder copyItems:NO];
//        NSArray *orderedArray = [filenamesForContent sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSArray *orderedArray = [self numericallyOrderArray:filenamesForContent];
        filenamesForContent = nil;
        filenamesForContent = [[NSArray alloc] initWithArray:orderedArray copyItems:NO];
        selectedStringIndex = 0;
        NSLog(@"syncroniseWithFilenameArray; selectedStringIndex = %lu, filenamesForContent: \n%@", selectedStringIndex, filenamesForContent);
        
    }
    return self;
}

-(NSArray*)numericallyOrderArray:(NSArray*)inArray {
    NSArray *orderedArray = [inArray sortedArrayUsingComparator:^(NSString* a, NSString* b) {
        return [a compare:b options:NSNumericSearch];
    }];
    return orderedArray;
}

-(void)loadView {
    self.view = [[NSView alloc] initWithFrame:proposedFrame];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(presentationQueue, ^{
        [self presentContentBasedOnSelectedStringIndex]; // !!!!
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
    if (isRunning) {
        if ([filenamesForContent count] == 0) {
            NSLog(@"nothing to present");
            isRunning = NO;
            // remove current subviews
            dispatch_async(dispatch_get_main_queue(), ^{
                // remove current subviews
                NSArray *subviews = [self.view subviews];
                for (NSView *view in subviews) {
                    [view removeFromSuperview];
                }
            });
            return;
        }
        NSUInteger numberOfLoops = 0;
        BOOL contentSuccessfullyLoaded = NO;
        CarouselContentView *newContentView; // assigned pointer of content view subclass
        while (!contentSuccessfullyLoaded) {
            if ([filenamesForContent count] > selectedStringIndex) {
                NSString *relativeFilenameString = [filenamesForContent objectAtIndex:selectedStringIndex];
                
                NSString *absoluteFilenameString = [NSString stringWithFormat:@"%@/%@", self.watchPath, relativeFilenameString];
                if (![fm fileExistsAtPath:absoluteFilenameString]) {
                    [self incrementSelectedStringIndex];
                } else {
                    CFStringRef fileExtension = (__bridge CFStringRef) [absoluteFilenameString pathExtension];
                    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
                    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
                        // image
                        CarouselImageView *imageContentView = [[CarouselImageView alloc] initWithFrame:self.view.frame waitTime:waitTimeForImages andPath:absoluteFilenameString];
                        if (imageContentView) {
                            newContentView = imageContentView; //
                            contentSuccessfullyLoaded = YES; //
                        } else {
                            [self incrementSelectedStringIndex];
                        }
                    }
                    else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) {
                        // video
                        CarouselVideoView *videoContentView = [[CarouselVideoView alloc] initWithFrame:self.view.frame andPath:absoluteFilenameString];
                        if (videoContentView) {
                            newContentView = videoContentView; //
                            contentSuccessfullyLoaded = YES; //
                        } else {
                            [self incrementSelectedStringIndex];
                        }
                    } else {
                        // not image or video
                        NSLog(@"%@ is neither picture or video", relativeFilenameString);
                        [self incrementSelectedStringIndex];
                    }
                    CFRelease(fileUTI);
                }
                
            } else {
                NSLog(@"selectStringIndex (%lu) goes beyond end of filenamesForContent array (%lu). this should not happen. setting to 0.", selectedStringIndex, [filenamesForContent count]);
                selectedStringIndex = 0;
            }
            numberOfLoops++;
            if (numberOfLoops > 1000) {
                NSLog(@"either no images or videos were found, or there are 1000 files in watch folder that are not images or videos.");
                isRunning = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    // remove current subviews
                    NSArray *subviews = [self.view subviews];
                    for (NSView *view in subviews) {
                        [view removeFromSuperview];
                    }
                });
                return;
            }
        }
        // begin content
        [newContentView setDelegate:self];
        [newContentView startContent];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // remove current subviews
            NSArray *subviews = [self.view subviews];
            for (NSView *view in subviews) {
                [view removeFromSuperview];
            }
            
            
            contentView = nil;
            contentView = newContentView;
//            [contentView setDelegate:self];
//            [contentView startContent];
            
            // add new view
            [self.view addSubview:contentView];
        });
        
        
    }
}

// CarouselContentDelegate
-(void)contentDidFinish:(id)content {
    dispatch_async(presentationQueue, ^{
        [self incrementSelectedStringIndex];
        [self presentContentBasedOnSelectedStringIndex];
    });
}

-(void)syncroniseWithFilenameArray:(NSArray*)inArray { // !! only call this on presentationQueue !!
    if ([inArray count] == 0) {
        NSLog(@"folder is empty");
        filenamesForContent = nil;
        filenamesForContent = [[NSArray alloc] initWithArray:inArray];
        selectedStringIndex = 0;
//        isRunning = NO;
        // remove current subviews
        return;
    }
    if ([filenamesForContent count] == 0) {
        // if own array is empty and inArray has just been populated, get filenames and sort
        NSArray *sortedArray = [self numericallyOrderArray:inArray];
        filenamesForContent = nil;
        filenamesForContent = [[NSArray alloc] initWithArray:sortedArray copyItems:NO];
        selectedStringIndex = 0;
    } else {
        NSLog(@"[inArray count] == %li", [inArray count]);
        NSLog(@"selectedStringIndex == %li, [filenamesForContent count] == %li", selectedStringIndex, [filenamesForContent count]);
        if (selectedStringIndex >= [filenamesForContent count]) {
            NSLog(@"dev: cannot sync filenames if current selection is greater than number of items in filenamesForContent");
            return;
        }
        // must keep place in carousel. if currently displayed filename is still in the folder, use string comparison in new array to find old position.
        // if currently displayed filename has been removed, add it before sorting, sort, find index, then remove
        NSString *stringAtSelectedIndex = [[filenamesForContent objectAtIndex:selectedStringIndex] copy]; // find this later to resume position
        // refresh array
        filenamesForContent = nil;
        filenamesForContent = [[NSMutableArray alloc] initWithArray:inArray];
        // find if filename is still in array (not by address, as string addresses are all different)
        NSString *foundFilename = nil;
        for (NSString *filename in filenamesForContent) {
            if ([filename isEqualToString:stringAtSelectedIndex]) {
                foundFilename = filename;
                break;
            }
        }
        NSUInteger updatedSelectedStringIndex;
        if (foundFilename) {
            // string wasn't removed, so will be easy to find the selection index again after sorting
            NSArray *sortedArray = [self numericallyOrderArray:filenamesForContent];
            filenamesForContent = nil;
            filenamesForContent = [[NSMutableArray alloc] initWithArray:sortedArray copyItems:NO];
            updatedSelectedStringIndex = [filenamesForContent indexOfObject:foundFilename];
        } else {
            NSMutableArray *mutableFilenameArray = [[NSMutableArray alloc] initWithArray:filenamesForContent copyItems:NO];
            // string was removed. add old string before sorting, then find it, find the index, then remove it, and decrement index by 1!
            [mutableFilenameArray addObject:stringAtSelectedIndex];
            NSArray *sortedArray = [self numericallyOrderArray:mutableFilenameArray];
            mutableFilenameArray = nil;
            mutableFilenameArray = [[NSMutableArray alloc] initWithArray:sortedArray copyItems:NO];
            NSUInteger indexOfAddedString = [mutableFilenameArray indexOfObject:stringAtSelectedIndex];
            [mutableFilenameArray removeObject:stringAtSelectedIndex];
            if (indexOfAddedString == 0) {
                indexOfAddedString = [mutableFilenameArray count] - 1; // go to end
                updatedSelectedStringIndex = indexOfAddedString;
            } else {
                updatedSelectedStringIndex = indexOfAddedString - 1;
            }
            filenamesForContent = nil;
            filenamesForContent = [[NSArray alloc] initWithArray:mutableFilenameArray copyItems:NO];
        }
        selectedStringIndex = updatedSelectedStringIndex;
    }
    
    // if carousel is not runnning, kick it off with new filenames
    if (!isRunning) {
        isRunning = YES;
        dispatch_async(presentationQueue, ^{
            selectedStringIndex = 0;
            [self presentContentBasedOnSelectedStringIndex];
        });
        
    }
    
    NSLog(@"syncroniseWithFilenameArray; selectedStringIndex = %lu, filenamesForContent: \n%@, isRunning = %i", selectedStringIndex, filenamesForContent, isRunning);
}


// delegate method
-(void)filenamesUpdatedInFolderWatcher {
    NSLog(@"delegate method called!");
    dispatch_async(presentationQueue, ^{
        [self syncroniseWithFilenameArray:folderWatcher.filenamesInWatchFolder];
    });
    
}

@end














