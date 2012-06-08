//
//  ACConversionWindow.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACConversionWindow.h"

static NSMutableSet * conversionWindowList = nil;

@implementation ACConversionWindow

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle icon:(NSImage *)icon {
    if ((self = [super initWithContentRect:NSMakeRect(0, 0, 420, 138) styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO])) {
        iconImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(30, 60, 64, 64)];
        [iconImageView setImage:icon];
        [self.contentView addSubview:iconImageView];
        
        titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(105, 88, 300, 35)];
        [titleLabel setBordered:NO];
        [titleLabel setSelectable:NO];
        [titleLabel setFont:[NSFont boldSystemFontOfSize:13]];
        [titleLabel setStringValue:title];
        [titleLabel setBackgroundColor:[NSColor clearColor]];
        [self.contentView addSubview:titleLabel];
        
        subtitleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(105, 54, 300, 27)];
        [subtitleLabel setBordered:NO];
        [subtitleLabel setSelectable:NO];
        [subtitleLabel setFont:[NSFont systemFontOfSize:11]];
        [subtitleLabel setStringValue:subtitle];
        [subtitleLabel setBackgroundColor:[NSColor clearColor]];
        [self.contentView addSubview:subtitleLabel];
        
        okayButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.frame.size.width - 120, 10, 110, 24)];
        [okayButton setBezelStyle:NSRoundedBezelStyle];
        [okayButton setTitle:@"Convert"];
        [okayButton setFont:[NSFont systemFontOfSize:13]];
        [self.contentView addSubview:okayButton];
        
        cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.frame.size.width - 250, 10, 130, 24)];
        [cancelButton setBezelStyle:NSRoundedBezelStyle];
        [cancelButton setTitle:@"Keep Format"];
        [cancelButton setFont:[NSFont systemFontOfSize:13]];
        [self.contentView addSubview:cancelButton];
        
        [self setDefaultButtonCell:[cancelButton cell]];
        [self setLevel:CGShieldingWindowLevel()];
    }
    return self;
}

- (void)show {
    if (!conversionWindowList) {
        conversionWindowList = [[NSMutableSet alloc] init];
    }
    [conversionWindowList addObject:self];
    
    CGRect screen = NSRectToCGRect([[NSScreen mainScreen] frame]);
    NSRect frame = self.frame;
    NSPoint origin = NSMakePoint(CGRectGetMidX(screen) - frame.size.width / 2,
                                 CGRectGetMidY(screen) - frame.size.height / 2);
    frame.origin = origin;
    
    NSRect startFrame = NSMakeRect(CGRectGetMidX(screen) - 2, CGRectGetMidY(screen) - 2, 4, 4);
    [self setFrame:startFrame display:YES];
    [self setAlphaValue:0];
    [self makeKeyAndOrderFront:self];
        
    [[NSAnimationContext currentContext] setDuration:0.3];
    [NSAnimationContext beginGrouping];
    [[self animator] setAlphaValue:1];
    [[self animator] setFrame:frame display:YES animate:YES];
    [NSAnimationContext endGrouping];
}

- (void)orderOut:(id)sender {
    [conversionWindowList removeObject:self];
}

@end
