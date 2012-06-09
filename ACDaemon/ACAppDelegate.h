//
//  ACAppDelegate.h
//  ACDaemon
//
//  Created by Alex Nichol on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACDaemonInterface.h"
#import "ACPreferences.h"
#import "ACRenameWatcher.h"
#import "ACPathMatcher.h"
#import "ACConfirmDialog.h"

#import "ACConverterPool.h"
#import "ACImageConverter.h"
#import "ACBundleLoader.h"

@interface ACAppDelegate : NSObject <NSApplicationDelegate, ACDaemonInterface, ACRenameWatcherDelegate> {
    NSConnection * connection;
    ACPreferences * preferences;
    ACRenameWatcher * watcher;
}

- (BOOL)shouldConvertPath:(NSString *)filePath;

@end
