//
//  ANAddButton.m
//  ControlBar
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANAddRemoveButton.h"

@implementation ANAddRemoveButton

@synthesize addButton;

- (id)init {
    if ((self = [super init])) {
        addButton = YES;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context inRect:(CGRect)buttonRect {
    if (enabled) {
        CGContextSetGrayFillColor(context, 0.25098, 1);
    } else {
        CGContextSetGrayFillColor(context, 0.50588, 1);
    }
    CGPoint plusPoint = CGPointMake(CGRectGetMidX(buttonRect) - 4, CGRectGetMidY(buttonRect) - 4);
    plusPoint.x = ceil(plusPoint.x);
    plusPoint.y = floor(plusPoint.y);
    CGContextFillRect(context, CGRectMake(plusPoint.x, plusPoint.y + 3, 8, 2));
    if (addButton) CGContextFillRect(context, CGRectMake(plusPoint.x + 3, plusPoint.y, 2, 8));
}

@end
