//
//  ACCancelButton.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACCancelButton.h"

@implementation ACCancelButton

@synthesize target;
@synthesize action;
@synthesize enabled;

+ (NSArray *)buttonImages {
    static NSArray * images = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        images = [[NSArray alloc] initWithObjects:[NSImage imageNamed:@"close1.png"],
                  [NSImage imageNamed:@"close2.png"],
                  [NSImage imageNamed:@"close3.png"],
                  [NSImage imageNamed:@"close4.png"], nil];
    });
    return images;
}

- (id)initWithFrame:(NSRect)frameRect target:(id)aTarget action:(SEL)anAction {
    if ((self = [self initWithFrame:frameRect])) {
        target = aTarget;
        action = anAction;
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame {
    if ((self = [super initWithFrame:frame])) {
        isPressed = NO;
        enabled = YES;
    }
    return self;
}

- (void)viewDidMoveToSuperview {
    if (trakcingArea) {
        [self removeTrackingArea:trakcingArea];
    }
    trakcingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseMoved|NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:trakcingArea];    
}

- (void)mouseEntered:(NSEvent *)theEvent {
    isHovered = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    isHovered = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    isPressed = YES;
    [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (isHovered && isPressed) {
        [self triggerEvent];
    }
    isPressed = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint point = [self.window.contentView convertPoint:[theEvent locationInWindow]
                                                   toView:self];
    if (NSPointInRect(point, self.bounds)) {
        isHovered = YES;
    } else {
        isHovered = NO;
    }
    [self setNeedsDisplay:YES];
}

- (void)triggerEvent {
    void * selfPtr = (__bridge void *)self;
    NSMethodSignature * signature = [target methodSignatureForSelector:action];
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:action];
    if ([signature numberOfArguments] > 2) {
        [invocation setArgument:&selfPtr atIndex:2];
    }
    [invocation invoke];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSInteger drawIndex = 0;
    if (enabled) {
        drawIndex += 1;
        if (isPressed) {
            drawIndex += 1;
        }
        if (isHovered) {
            drawIndex += 1;
        }
    }
    NSImage * image = [[[self class] buttonImages] objectAtIndex:drawIndex];
    [image drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

@end
