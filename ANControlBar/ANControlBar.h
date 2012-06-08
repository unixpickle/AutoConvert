//
//  ANControlBar.h
//  ControlBar
//
//  Created by Alex Nichol on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANBarButton.h"

#define kControlBarHeight 22

@interface ANControlBar : NSView {
    NSMutableArray * buttons;
    __weak ANBarButton * pressedButton;
    BOOL isPressing;
}

- (void)addButton:(ANBarButton *)button;
- (void)removeButton:(ANBarButton *)button;

@end
