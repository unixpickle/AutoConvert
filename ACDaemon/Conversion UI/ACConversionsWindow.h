//
//  ACConversionsWindow.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACConverter.h"

@interface ACConversionsWindow : NSWindow {
    
}

+ (ACConversionsWindow *)sharedConversionsWindow;
- (void)pushConverter:(ACConverter *)converter;

@end
