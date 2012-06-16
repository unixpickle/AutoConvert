//
//  ACAppDelegate.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANControlBar.h"
#import "ANAddRemoveButton.h"
#import "ACPreferences.h"
#import "ANAutoLaunch.h"
#import "ACDaemonInterface.h"
#import "ACDaemonWatcher.h"

@interface ACAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    IBOutlet NSTableView * excludeTable;
    IBOutlet ANControlBar * excludeControlBar;
    ANAddRemoveButton * excludeAddButton;
    ANAddRemoveButton * excludeRemoveButton;
    
    IBOutlet NSTableView * includeTable;
    IBOutlet ANControlBar * includeControlBar;
    ANAddRemoveButton * includeAddButton;
    ANAddRemoveButton * includeRemoveButton;
    
    IBOutlet NSButton * autoLaunchCheckbox;
    IBOutlet NSButton * launchButton;
    
    ACPreferences * preferences;
    ANAutoLaunch * autoLaunch;
    ACDaemonWatcher * daemonWatcher;
}

- (void)includeAddPressed:(id)sender;
- (void)includeRemovePressed:(id)sender;
- (void)excludeAddPressed:(id)sender;
- (void)excludeRemovePressed:(id)sender;

- (IBAction)autoLaunchChanged:(id)sender;
- (IBAction)launchDaemon:(id)sender;
- (void)daemonStatusChanged:(NSNotification *)notification;

- (BOOL)notifyDaemonChange;

@end
