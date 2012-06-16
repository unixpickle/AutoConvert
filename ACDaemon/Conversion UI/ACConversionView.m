//
//  ACConversionView.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACConversionView.h"

static CGSize sizeForString(NSString * myString, NSFont * myFont);

@implementation ACConversionView

@synthesize converter;
@synthesize backgroundColor;
@synthesize drawDivider;
@synthesize delegate;

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

- (id)initWithWidth:(CGFloat)width converter:(ACConverter *)aConverter {
    if ((self = [super initWithFrame:NSMakeRect(0, 0, width, kACConversionViewHeight)])) {
        converter = aConverter;
        drawDivider = NO;
        backgroundColor = [NSColor whiteColor];
        
        progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(60, 26, width - 94, 12)];
        [progressIndicator setIndeterminate:NO];
        [progressIndicator setMaxValue:1];
        [progressIndicator setDoubleValue:0];
        [progressIndicator setControlSize:NSMiniControlSize];
        [self addSubview:progressIndicator];
        
        cancelButton = [[ACCancelButton alloc] initWithFrame:NSMakeRect(371, 26, kACCancelButtonSize, kACCancelButtonSize)];
        [cancelButton setTarget:self];
        [cancelButton setAction:@selector(cancelPressed:)];
        [self addSubview:cancelButton];
        
        subtitleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(60, 10, 320, 11)];
        [subtitleLabel setBordered:NO];
        [subtitleLabel setSelectable:NO];
        [subtitleLabel setBackgroundColor:[NSColor clearColor]];
        [subtitleLabel setStringValue:@"0% complete"];
        [subtitleLabel setFont:[NSFont systemFontOfSize:9]];
        [self addSubview:subtitleLabel];
        
        titleLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(60, 38 + 8, 320, 14)];
        [titleLabel setBordered:NO];
        [titleLabel setSelectable:NO];
        [titleLabel setBackgroundColor:[NSColor clearColor]];
        [titleLabel setStringValue:[self shrinkText:[converter conversionTitle] withLabel:titleLabel]];
        [titleLabel setFont:[NSFont systemFontOfSize:11]];
        [self addSubview:titleLabel];
        
        // 10, 22
        NSImage * icon = [[NSWorkspace sharedWorkspace] iconForFile:converter.file];
        iconImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(10, 22, 32, 32)];
        [iconImageView setImage:icon];
        [self addSubview:iconImageView];
        
        [converter setDelegate:self];
        [converter beginConverting];
    }
    return self;
}

- (void)cancelPressed:(id)sender {
    [converter cancelConverting];
    [delegate conversionViewFinished:self];
}

- (void)okayPressed:(id)sender {
    [delegate conversionViewFinished:self];
}

#pragma mark UI Drawing

- (NSString *)shrinkText:(NSString *)text withLabel:(NSTextField *)label {
    CGFloat maxWidth = label.frame.size.width;
    NSFont * font = [label font];
    NSString * testString = text;
    NSInteger cutLength = 1, cutStart = [text length] / 2;
    while (sizeForString(testString, font).width > maxWidth) {
        cutLength += 1;
        cutStart = [text length] / 2 + cutLength / 2;
        if (cutStart - cutLength < 0) cutStart++;
        if (cutStart >= [text length]) return nil;
        testString = [text stringByReplacingCharactersInRange:NSMakeRange(cutStart - cutLength, cutLength)
                                                   withString:@"..."];
    }
    return testString;
}

- (void)drawRect:(NSRect)dirtyRect {
    [backgroundColor set];
    NSRectFill(self.bounds);
    if (drawDivider) {
        [[NSColor colorWithDeviceWhite:0.66667 alpha:1] set];
        NSRectFill(NSMakeRect(0, 0, self.frame.size.width, 1));
    }
}

#pragma mark - Converter -

- (void)converter:(ACConverter *)aConverter progressUpdate:(float)progress {
    [progressIndicator setDoubleValue:progress];
    NSString * subtitle = [converter conversionSubtitle];
    NSString * shrunk = [self shrinkText:subtitle withLabel:subtitleLabel];
    [subtitleLabel setStringValue:shrunk];
}

- (void)converter:(ACConverter *)aConverter failedWithError:(NSError *)error {
    NSLog(@"Conversion error: %@", error);
    okayButton = [[NSButton alloc] initWithFrame:NSMakeRect(self.frame.size.width - 106, 10, 96, 20)];
    [okayButton.cell setControlSize:NSSmallControlSize]; 
    [okayButton setBezelStyle:NSRoundedBezelStyle];
    [okayButton setTitle:@"OK"];
    [okayButton setTarget:self];
    [okayButton setAction:@selector(okayPressed:)];
    [okayButton setFont:[NSFont systemFontOfSize:11]];
    [self addSubview:okayButton];
    
    NSString * errorString = [NSString stringWithFormat:@"Failed to convert %@", [[converter file] lastPathComponent]];
    NSString * shrunk = [self shrinkText:errorString withLabel:titleLabel];
    [titleLabel setStringValue:shrunk];
    
    [subtitleLabel removeFromSuperview];
    [cancelButton removeFromSuperview];
    [progressIndicator removeFromSuperview];
}

- (void)converterFinished:(ACConverter *)converter {
    [delegate conversionViewFinished:self];
}

@end

static CGSize sizeForString(NSString * myString, NSFont * myFont) {
    NSTextStorage * textStorage = [[NSTextStorage alloc] initWithString:myString];
    NSTextContainer * textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(FLT_MAX, FLT_MAX)];
    NSLayoutManager * layoutManager = [[NSLayoutManager alloc] init];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:myFont
                        range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager usedRectForTextContainer:textContainer].size;
}
