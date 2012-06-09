//
//  ACFinderFocus.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACFinderFocus.h"

static NSMutableSet * windows = nil;

@implementation ACFinderFocus

+ (BOOL)isFinderFrontmost {
    return [[CarbonAppProcess currentProcess] isFinder];
}

+ (BOOL)isCurrentAppFrontmost {
    return [[CarbonAppProcess currentProcess] isFrontmost];
}

+ (void)focusFinder {
    FinderApplication * app = [SBApplication applicationWithBundleIdentifier:@"com.apple.finder"];
    if (!app || ![app isRunning]) {
        return;
    }
    SBElementArray * selArray = app.selection.get;
    if ([selArray count] == 0) {
        [app activate];
    } else {
        FinderWindow * window = [[[selArray objectAtIndex:0] container].get containerWindow].get;
        if ([window isKindOfClass:NSClassFromString(@"FinderFinderWindow")]) {
            [app activate];
        }
    }
}

+ (NSInteger)openWindowCount {
    return [windows count];
}

+ (void)addOpenWindow:(NSWindow *)window {
    if (!windows) windows = [NSMutableSet new];
    [windows addObject:[NSValue valueWithPointer:(__bridge void *)window]];
    if ([windows count] == 1) {
        if (![self isCurrentAppFrontmost]) {
            [[CarbonAppProcess currentProcess] makeFrontmost];
        }
    }
}

+ (void)removeOpenWindow:(NSWindow *)window {
    if (!windows) windows = [NSMutableSet new];
    [windows removeObject:[NSValue valueWithPointer:(__bridge void *)window]];
    if ([windows count] == 0) {
        if ([self isCurrentAppFrontmost]) {
            [self focusFinder];
        }
    }
}

@end
