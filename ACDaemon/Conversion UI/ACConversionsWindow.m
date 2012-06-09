//
//  ACConversionsWindow.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACConversionsWindow.h"

@interface ACConversionsWindow (Private)

- (void)layoutConversionViews;

@end

@implementation ACConversionsWindow

+ (ACConversionsWindow *)sharedConversionsWindow {
    static ACConversionsWindow * window = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [[ACConversionsWindow alloc] init];
    });
    return window;
}

- (id)init {
    NSRect screen = [[NSScreen mainScreen] frame];
    CGFloat y = screen.size.height - 500;
    if ((self = [super initWithContentRect:NSMakeRect(300, y, 400, 1)
                                 styleMask:(NSTitledWindowMask | NSMiniaturizableWindowMask)
                                   backing:NSBackingStoreBuffered defer:NO])) {
        conversionViews = [[NSMutableArray alloc] init];
        self.title = @"Conversions";
        [self setLevel:CGShieldingWindowLevel()];
        [self setAcceptsMouseMovedEvents:YES];
        self.contentView = [[ACMouseView alloc] initWithFrame:NSMakeRect(0, 0, 400, 1)];
    }
    return self;
}

- (void)pushConverter:(ACConverter *)converter {
    ACConversionView * view = [[ACConversionView alloc] initWithWidth:[self.contentView frame].size.width converter:converter];
    [view setDelegate:self];
    [conversionViews addObject:view];
    [self.contentView addSubview:view];
    [self layoutConversionViews];
    if (!isVisible) {
        [self makeKeyAndOrderFront:self];
        [ACFinderFocus addOpenWindow:self];
        isVisible = YES;
    }
}

- (void)layoutConversionViews {
    CGFloat totalHeight = [conversionViews count] * kACConversionViewHeight;
    CGFloat y = totalHeight - kACConversionViewHeight;
    for (int i = 0; i < [conversionViews count]; i++) {
        ACConversionView * view = [conversionViews objectAtIndex:i];
        if (i % 2 == 0) {
            view.backgroundColor = [NSColor colorWithCalibratedWhite:0.98 alpha:1];
        } else {
            view.backgroundColor = [NSColor colorWithCalibratedRed:0.94118 green:0.976 blue:0.996 alpha:1];
        }
        view.frame = NSMakeRect(0, y, [self.contentView frame].size.width, view.frame.size.height);
        view.drawDivider = (i + 1 < [conversionViews count] ? YES : NO);
        [view setNeedsDisplay:YES];
        y -= view.frame.size.height;
    }
    NSRect frame = self.frame;
    frame.size.height = totalHeight;
    NSRect frameRect = [self frameRectForContentRect:frame];
    frameRect.origin.y -= (frameRect.size.height - self.frame.size.height);
    [self setFrame:frameRect display:YES];
}

- (void)conversionViewFinished:(id)sender {
    [conversionViews removeObject:sender];
    [sender removeFromSuperview];
    if ([conversionViews count] == 0) {
        [self orderOut:self];
        [ACFinderFocus removeOpenWindow:self];
        isVisible = NO;
    }
    [self layoutConversionViews];
}

- (void)conversionViewResized:(id)sender {
    [self layoutConversionViews];
}

@end
