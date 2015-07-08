//
//  FolderWatcher.m
//  ContentCarousel
//
//  Created by Simon Haycock on 06/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import "FolderWatcher.h"
#include <CoreServices/CoreServices.h>

@implementation FolderWatcher {
    NSFileManager *fileManager;
    id <FolderWatcherDelegate> delegate;
}

@synthesize filenamesInWatchFolder;

static void cCallback(
                       ConstFSEventStreamRef streamRef,
                       void *clientCallBackInfo,
                       size_t numEvents,
                       void *eventPaths,
                       const FSEventStreamEventFlags eventFlags[],
                      const FSEventStreamEventId eventIds[])
{
    const FSEventStreamEventFlags *pEventFlags = eventFlags;
    const FSEventStreamEventId *pEventIds = eventIds;
    FolderWatcher *folderWatcher = (__bridge FolderWatcher*)clientCallBackInfo;
    [folderWatcher notifyEvents:numEvents paths:eventPaths withFlags:pEventFlags andEventIDs:pEventIds];
}


-(instancetype)initWithPath:(NSString*)watchPath {
    self = [super init];
    if (self) {
        NSLog(@"watchPath chosen in FolderWatcher: %@", watchPath);
        
        _watchFolderPath = watchPath;
        fileManager = [NSFileManager defaultManager];
        
        // populate set with current filenames in folder
        NSError *error = [self syncFilenamesWithFolder];
        if (error) {
            return nil;
        }
        
        // create FSEventStream
        CFStringRef myPath = (__bridge CFStringRef)(_watchFolderPath);
        CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&myPath, 1, NULL);
        FSEventStreamContext context = {0,(__bridge void *)(self),NULL,NULL,NULL};
        FSEventStreamRef stream;
        CFAbsoluteTime latency = 3.0; /* Latency in seconds */
        
        FSEventStreamCallback myCallbackFunction = &cCallback;
        
        /* Create the stream, passing in a callback */
        stream = FSEventStreamCreate(NULL,
                                     myCallbackFunction,
                                     &context,
                                     pathsToWatch,
                                     kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                     latency,
                                     kFSEventStreamCreateFlagUseCFTypes /* Flags explained in reference */
                                     );
        
        FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        FSEventStreamStart(stream);
        
    }
    return self;
}

-(NSError*)syncFilenamesWithFolder {  // called when contents of watch folder has changed. array 'sortedFilenamesInWatchFolder' is updated
    NSError *error = nil;
    filenamesInWatchFolder = nil;
    filenamesInWatchFolder = [fileManager contentsOfDirectoryAtPath:self.watchFolderPath error:&error];
    if (error) {
        NSLog(@"error reading watch folder");
        return error;
    }
    
    // tell delegate
    if (delegate) {
        [delegate filenamesUpdatedInFolderWatcher];
    }
    
    return nil;
    
}

-(void)setDelegate:(id <FolderWatcherDelegate>)inDelegate {
    delegate = inDelegate;
//    [self syncFilenamesWithFolder];
}

-(void)notifyEvents:(size_t)inNumberOfEvents paths:(void*)inPaths withFlags:(const FSEventStreamEventFlags*)inFlags andEventIDs:(const FSEventStreamEventId*)eventIDs {
    
    /*
    NSUInteger numOfEvents = inNumberOfEvents;
    NSArray *paths = (__bridge NSArray*)inPaths;
     */
    NSLog(@"!!CHANGE MADE TO CONTENTS OF FOLDER!!! sync started");
    [self syncFilenamesWithFolder];
    
}









@end
