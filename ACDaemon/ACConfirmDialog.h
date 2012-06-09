//
//  ACConfirmDialog.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACConverter.h"
#import "ACConversionsWindow.h"
#import "ACFinderFocus.h"

@interface ACConfirmDialog : NSWindow {
    ACConverter * converter;
    NSTextField * titleLabel;
    NSTextField * subtitleLabel;
    NSImageView * iconImageView;
    NSButton * okayButton;
    NSButton * cancelButton;
}

+ (NSInteger)confirmDialogCount;

- (id)initWithConverter:(ACConverter *)converter icon:(NSImage *)icon;
- (void)show;

- (void)okayPressed:(id)sender;
- (void)cancelPressed:(id)sender;

@end
