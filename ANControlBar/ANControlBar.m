//
//  ANControlBar.m
//  ControlBar
//
//  Created by Alex Nichol on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANControlBar.h"

@interface ANControlBar (Private)

- (void)drawGradient:(CGContextRef)context;
- (ANBarButton *)buttonForWindowPoint:(NSPoint)windowPoint;

@end

@implementation ANControlBar

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        buttons = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        buttons = [[NSMutableArray alloc] init];        
    }
    return self;
}

- (void)addButton:(ANBarButton *)button {
    [buttons addObject:button];
    [self setNeedsDisplay:YES];
}

- (void)removeButton:(ANBarButton *)button {
    [buttons removeObject:button];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint point = [theEvent locationInWindow];
    ANBarButton * button = [self buttonForWindowPoint:point];
    if (!button.enabled) {
        pressedButton = nil;
        return;
    }
    isPressing = YES;
    pressedButton = button;
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint point = [theEvent locationInWindow];
    BOOL lastValue = isPressing;
    if ([self buttonForWindowPoint:point] != pressedButton) {
        isPressing = NO;
    } else {
        isPressing = YES;
    }
    if (lastValue != isPressing) [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSPoint point = [theEvent locationInWindow];
    if ([self buttonForWindowPoint:point] == pressedButton) {
        // call button action
        [pressedButton invoke];
    }
    pressedButton = nil;
    [self setNeedsDisplay:YES];
}

#pragma mark - Drawing -

- (void)drawRect:(NSRect)dirtyRect {
    // border: 0.5922
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetGrayFillColor(context, 0.5922, 1);
    CGContextFillRect(context, CGRectMake(0, 1, self.frame.size.width, self.frame.size.height - 1));
    
    // stroke the gradient
    [self drawGradient:context];
    
    // bottom white bar
    CGContextSetGrayFillColor(context, 0.94118, 1);
    CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, 1));
    
    // buttons
    CGFloat x = 1;
    CGFloat buttonY = 2;
    CGFloat buttonHeight = self.frame.size.height - 3;
    for (ANBarButton * button in buttons) {
        CGRect buttonRect = CGRectMake(x, buttonY, kANBarButtonWidth, buttonHeight);
        [button drawInContext:context inRect:buttonRect];
        
        if (pressedButton == button && isPressing) {
            CGContextSetGrayFillColor(context, 0, 0.5);
            CGContextFillRect(context, buttonRect);
        }
        
        CGContextSetGrayFillColor(context, 0.5922, 1);
        x += kANBarButtonWidth + 1;
        CGContextFillRect(context, CGRectMake(x - 1, 2, 1, buttonHeight));
    }
}

#pragma mark - Private -

- (void)drawGradient:(CGContextRef)context {
    CGContextSaveGState(context);
    NSRect rect = CGRectMake(1, 2, self.frame.size.width - 2, self.frame.size.height - 3);
    CGContextClipToRect(context, rect);
    CGFloat colors[] = {0.96863, 1, 0.980392, 1, 0.89412, 1, 0.90588, 1};
    CGFloat locations[] = {0, 0.460, 0.5, 1};
    CGColorSpaceRef space = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, 4);
    CGContextDrawLinearGradient(context, gradient,
                                CGPointMake(1, self.frame.size.height - 1),
                                CGPointMake(1, 2),
                                0);
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(space);
}

- (ANBarButton *)buttonForWindowPoint:(NSPoint)windowPoint {
    NSPoint localPoint = [self.window.contentView convertPoint:windowPoint toView:self];
    CGPoint lookupPoint = NSPointToCGPoint(localPoint);
    CGFloat x = 1;
    CGFloat buttonY = 2;
    CGFloat buttonHeight = self.frame.size.height - 3;
    for (ANBarButton * button in buttons) {
        CGRect buttonRect = CGRectMake(x, buttonY, kANBarButtonWidth, buttonHeight);
        x += kANBarButtonWidth + 1;
        if (CGRectContainsPoint(buttonRect, lookupPoint)) {
            return button;
        }
    }
    return nil;
}

@end
