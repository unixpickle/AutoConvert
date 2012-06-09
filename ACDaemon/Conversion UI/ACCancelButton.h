//
//  ACCancelButton.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACMouseView.h"

#define kACCancelButtonSize 14

@interface ACCancelButton : ACMouseView {
    BOOL isPressed;
    BOOL enabled;
    BOOL isHovered;
    __weak id target;
    SEL action;
    NSTrackingArea * trakcingArea;
}

@property (nonatomic, weak) id target;
@property (readwrite) SEL action;
@property (readwrite, getter = isEnabled) BOOL enabled;

+ (NSArray *)buttonImages;

- (id)initWithFrame:(NSRect)frameRect target:(id)aTarget action:(SEL)anAction;
- (void)triggerEvent;

@end
