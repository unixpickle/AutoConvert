//
//  ACFinderFocus.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarbonAppProcess.h"
#import "Finder.h"

@interface ACFinderFocus : NSObject {
    
}

+ (BOOL)isFinderFrontmost;
+ (BOOL)isCurrentAppFrontmost;
+ (void)focusFinder;
+ (NSInteger)openWindowCount;
+ (void)addOpenWindow:(NSWindow *)window;
+ (void)removeOpenWindow:(NSWindow *)window;

@end
