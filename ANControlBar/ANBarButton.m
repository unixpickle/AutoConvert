//
//  ANBarButton.m
//  ControlBar
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANBarButton.h"

CGSize sizeForString(NSString * myString, NSFont * myFont, CGFloat myWidth) {
    NSTextStorage * textStorage = [[NSTextStorage alloc] initWithString:myString];
    NSTextContainer * textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(myWidth, FLT_MAX)];
    NSLayoutManager * layoutManager = [[NSLayoutManager alloc] init];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:myFont
                        range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager usedRectForTextContainer:textContainer].size;
}

@implementation ANBarButton

@synthesize target;
@synthesize action;
@synthesize title;
@synthesize enabled;

- (id)init {
    if ((self = [super init])) {
        enabled = YES;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context inRect:(CGRect)buttonRect {
    if (!title) return;
    // 129, 64 (enabled)
    NSColor * textColor = (enabled ? [NSColor colorWithCalibratedWhite:0.25098 alpha:1] : [NSColor colorWithCalibratedWhite:0.50588 alpha:1]);
    NSFont * drawFont = [NSFont boldSystemFontOfSize:14];
    
    CGSize size = sizeForString(title, drawFont, buttonRect.size.width);
    CGRect drawRect = CGRectMake(CGRectGetMidX(buttonRect) - size.width / 2,
                                 CGRectGetMidY(buttonRect) - size.height / 2 + 2,
                                 size.width, size.height);
    
    // TODO: figure out a way to actually use the context here...
    NSDictionary * attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                 textColor, NSForegroundColorAttributeName,
                                 drawFont, NSFontAttributeName, 
                                 [NSNumber numberWithFloat:-3], NSStrokeWidthAttributeName, nil];
    [title drawInRect:drawRect withAttributes:attributes];
}

- (void)invoke {
    void * selfPtr = (__bridge void *)self;
    if (!target || !action) return;
    NSMethodSignature * signature = [target methodSignatureForSelector:action];
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:action];
    if ([signature numberOfArguments] > 2) {
        [invocation setArgument:&selfPtr atIndex:2];
    }
    [invocation invoke];
}

@end
