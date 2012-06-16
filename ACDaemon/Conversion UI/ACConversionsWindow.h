//
//  ACConversionsWindow.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACConversionView.h"
#import "ACFinderFocus.h"

@interface ACConversionsWindow : NSWindow <ACConversionViewDelegate> {
    NSMutableArray * conversionViews;
    BOOL isVisible;
}

+ (ACConversionsWindow *)sharedConversionsWindow;
- (void)pushConverter:(ACConverter *)converter;
- (void)killConverters;

@end
