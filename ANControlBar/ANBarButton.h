//
//  ANBarButton.h
//  ControlBar
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define kANBarButtonWidth 23

@interface ANBarButton : NSObject {
    __weak id target;
    SEL action;
    NSString * title;
    BOOL enabled;
}

@property (nonatomic, weak) id target;
@property (readwrite) SEL action;
@property (nonatomic, strong) NSString * title;
@property (readwrite) BOOL enabled;

- (void)drawInContext:(CGContextRef)context inRect:(CGRect)buttonRect;
- (void)invoke;

@end
