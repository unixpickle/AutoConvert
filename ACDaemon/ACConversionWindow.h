//
//  ACConversionWindow.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACConversionWindow : NSWindow {
    NSTextField * titleLabel;
    NSTextField * subtitleLabel;
    NSImageView * iconImageView;
    NSButton * okayButton;
    NSButton * cancelButton;
}

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle icon:(NSImage *)icon;
- (void)show;

@end
