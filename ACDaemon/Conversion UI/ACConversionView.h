//
//  ACConversionView.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACMouseView.h"
#import "ACConverter.h"
#import "ACCancelButton.h"

#define kACConversionViewHeight 68

@class ACConversionView;

@protocol ACConversionViewDelegate <NSObject>

- (void)conversionViewFinished:(id)sender;
- (void)conversionViewResized:(id)sender;

@end

@interface ACConversionView : ACMouseView <ACConverterDelegate> {
    ACConverter * converter;
    NSColor * backgroundColor;
    BOOL drawDivider;
    
    NSImageView * iconImageView;
    NSTextField * titleLabel;
    NSTextField * subtitleLabel;
    NSProgressIndicator * progressIndicator;
    ACCancelButton * cancelButton;
    
    NSButton * okayButton;
    
    __unsafe_unretained id<ACConversionViewDelegate> delegate;
}

@property (readonly) ACConverter * converter;
@property (nonatomic, retain) NSColor * backgroundColor;
@property (readwrite) BOOL drawDivider;
@property (nonatomic, assign) id<ACConversionViewDelegate> delegate;

- (id)initWithWidth:(CGFloat)width converter:(ACConverter *)aConverter;
- (void)cancelPressed:(id)sender;
- (void)okayPressed:(id)sender;

@end
