//
//  ACConversionView.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACConversionView.h"

@implementation ACConversionView

@synthesize converter;
@synthesize backgroundColor;
@synthesize drawDivider;
@synthesize delegate;

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (id)initWithWidth:(CGFloat)width converter:(ACConverter *)aConverter {
    if ((self = [super initWithFrame:NSMakeRect(0, 0, width, kACConversionViewHeight)])) {
        converter = aConverter;
        drawDivider = NO;
        backgroundColor = [NSColor whiteColor];
        
        progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(60, 26, width - 94, 12)];
        [progressIndicator setIndeterminate:NO];
        [progressIndicator setMaxValue:1];
        [progressIndicator setDoubleValue:0];
        [progressIndicator setControlSize:NSMiniControlSize];
        [self addSubview:progressIndicator];
        
        cancelButton = [[ACCancelButton alloc] initWithFrame:NSMakeRect(371, 26, kACCancelButtonSize, kACCancelButtonSize)];
        [cancelButton setTarget:self];
        [cancelButton setAction:@selector(cancelPressed:)];
        [self addSubview:cancelButton];
        
        subtitleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(60, 10, 320, 10)];
        [subtitleLabel setBordered:NO];
        [subtitleLabel setSelectable:NO];
        [subtitleLabel setBackgroundColor:[NSColor clearColor]];
        [subtitleLabel setStringValue:@"0% complete"];
        [subtitleLabel setFont:[NSFont systemFontOfSize:9]];
        [self addSubview:subtitleLabel];
        
        titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(60, 38 + 8, 320, 14)];
        [titleLabel setBordered:NO];
        [titleLabel setSelectable:NO];
        [titleLabel setBackgroundColor:[NSColor clearColor]];
        [titleLabel setStringValue:[converter conversionTitle]];
        [titleLabel setFont:[NSFont systemFontOfSize:11]];
        [self addSubview:titleLabel];
        
        // 10, 22
        NSImage * icon = [[NSWorkspace sharedWorkspace] iconForFile:converter.file];
        iconImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(10, 22, 32, 32)];
        [iconImageView setImage:icon];
        [self addSubview:iconImageView];
        
        [converter setDelegate:self];
        [converter beginConverting];
    }
    return self;
}

- (void)cancelPressed:(id)sender {
    [converter cancelConverting];
    [delegate conversionViewFinished:self];
}

- (void)okayPressed:(id)sender {
    [delegate conversionViewFinished:self];
}

- (void)drawRect:(NSRect)dirtyRect {
    [backgroundColor set];
    NSRectFill(self.bounds);
    if (drawDivider) {
        [[NSColor colorWithDeviceWhite:0.66667 alpha:1] set];
        NSRectFill(NSMakeRect(0, 0, self.frame.size.width, 1));
    }
}

#pragma mark - Converter -

- (void)converter:(ACConverter *)converter progressUpdate:(float)progress {
    [progressIndicator setDoubleValue:progress];
    NSString * status = [NSString stringWithFormat:@"%d%% complete", (int)round(progress * 100.0f)];
    [subtitleLabel setStringValue:status];
}

- (void)converter:(ACConverter *)aConverter failedWithError:(NSError *)error {
    okayButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.frame.size.width - 106, 10, 96, 20)];
    [okayButton.cell setControlSize:NSSmallControlSize]; 
    [okayButton setBezelStyle:NSRoundedBezelStyle];
    [okayButton setTitle:@"OK"];
    [okayButton setTarget:self];
    [okayButton setAction:@selector(okayPressed:)];
    [okayButton setFont:[NSFont systemFontOfSize:11]];
    [self addSubview:okayButton];
    
    NSString * errorString = [NSString stringWithFormat:@"Failed to convert %@", [[converter file] lastPathComponent]];
    [titleLabel setStringValue:errorString];
    
    [subtitleLabel removeFromSuperview];
    [cancelButton removeFromSuperview];
    [progressIndicator removeFromSuperview];
}

- (void)converterFinished:(ACConverter *)converter {
    [delegate conversionViewFinished:self];
}

@end
