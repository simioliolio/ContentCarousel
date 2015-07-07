//
//  FolderWatcher.h
//  ContentCarousel
//
//  Created by Simon Haycock on 06/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FolderWatcherDelegate <NSObject>

-(void)filenamesUpdatedInFolderWatcher;

@end


@interface FolderWatcher : NSObject


@property (strong, readonly) NSString *watchFolderPath;

/* unordered array of filenames
 */
@property (strong, readonly) NSArray *filenamesInWatchFolder;

/* initialiser returns nil if path is not readable
 */
-(instancetype)initWithPath:(NSString*)watchPath;

/* setting delegate causes delegate method to be called
 * straight away, to provide initial sync
 */
-(void)setDelegate:(id <FolderWatcherDelegate>)inDelegate;

@end


