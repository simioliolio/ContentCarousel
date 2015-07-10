//
//  CarouselContentView.h
//  ContentCarousel
//
//  Created by Simon Haycock on 07/07/2015.
//  Copyright (c) 2015 oxygn. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol CarouselContentDelegate <NSObject>

-(void)contentDidFinish:(id)content;

@end


@interface CarouselContentView : NSView

@property (readwrite) id <CarouselContentDelegate> delegate;
@property (readonly) NSString *filename;
@property (readonly) BOOL isReadyToView;

-(void)tellDelegateContentHasFinished;

/* subclass these
 */
-(void)startContent;
-(void)stopContent;

@end






