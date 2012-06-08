//
//  ACAppDelegate.m
//  ACDaemon
//
//  Created by Alex Nichol on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACAppDelegate.h"

@implementation ACAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    preferences = [[ACPreferences alloc] init];
    if (!preferences) {
        NSLog(@"Failed to access preferences!");
        exit(1);
    }
    
    connection = [NSConnection new];
    [connection setRootObject:self];
    if ([connection registerName:@"ACDaemon"] == NO) {
        NSLog(@"Failed to register for distributed objects!");
        exit(1);
    }
    
    watcher = [[ACRenameWatcher alloc] initWithPath:@"/"];
    [watcher setDelegate:self];
    [watcher startWatching];
    
    [[ACConverterPool sharedPool] addConverterClass:[ACPNGJPGConverter class]];
}

- (void)applicationDidResignActive:(NSNotification *)notification {
	[[FocusManager sharedFocusManager] setSecondaryMainApp:[CarbonAppProcess frontmostProcess]];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification {
	CarbonAppProcess * frontmost = [CarbonAppProcess frontmostProcess];
	CarbonAppProcess * current = [CarbonAppProcess currentProcess];
	if (![frontmost isEqual:current]) {
		[[FocusManager sharedFocusManager] setSecondaryMainApp:[CarbonAppProcess frontmostProcess]];
	}
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [watcher stopWatching];
}

- (void)preferencesChanged {
    NSLog(@"Preferences changed!");
    [preferences reloadFromFile];
}

#pragma mark - File Watching -

- (void)renameWatcher:(ACRenameWatcher *)sender path:(NSString *)oldPath movedTo:(NSString *)newPath {
    NSArray * oldComps = [[oldPath stringByDeletingLastPathComponent] pathComponents];
    NSArray * newComps = [[newPath stringByDeletingLastPathComponent] pathComponents];
    if (![oldComps isEqualToArray:newComps]) {
        return;
    }
    NSString * oldExt = [[oldPath pathExtension] lowercaseString];
    NSString * newExt = [[newPath pathExtension] lowercaseString];
    if (![oldExt isEqualToString:newExt]) {
        if (![self shouldConvertPath:newPath]) {
            NSLog(@"Ignoring file: %@", newPath);
            return;
        }
        ACConverter * converter = [[ACConverterPool sharedPool] converterForFile:newPath source:oldExt destination:newExt];
        NSLog(@"Converter: %@", converter);
        if (converter) {
            NSImage * icon = [NSImage imageNamed:@"icon.png"];
            ACConfirmDialog * window = [[ACConfirmDialog alloc] initWithConverter:converter
                                                                                   icon:icon];
            [[FocusManager sharedFocusManager] forceAppFocus];
            [window show];
            //[[FocusManager sharedFocusManager] resignAppFocus];
        }
    }
}

- (BOOL)shouldConvertPath:(NSString *)filePath {
    ACPathMatcher * matcher = [[ACPathMatcher alloc] initWithInclude:[preferences includePaths]
                                                             exclude:[preferences excludePaths]];
    return [matcher testPathString:filePath];
}

@end
