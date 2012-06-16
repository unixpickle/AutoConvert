//
//  ACAppDelegate.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACAppDelegate.h"

@implementation ACAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    excludeAddButton = [[ANAddRemoveButton alloc] init];
    excludeAddButton.target = self;
    excludeAddButton.action = @selector(excludeAddPressed:);
    
    excludeRemoveButton = [[ANAddRemoveButton alloc] init];
    excludeRemoveButton.addButton = NO;
    excludeRemoveButton.target = self;
    excludeRemoveButton.action = @selector(excludeRemovePressed:);
    
    includeAddButton = [[ANAddRemoveButton alloc] init];
    includeAddButton.target = self;
    includeAddButton.action = @selector(includeAddPressed:);
    
    includeRemoveButton = [[ANAddRemoveButton alloc] init];
    includeRemoveButton.addButton = NO;
    includeRemoveButton.target = self;
    includeRemoveButton.action = @selector(includeRemovePressed:);
    
    [excludeControlBar addButton:excludeAddButton];
    [excludeControlBar addButton:excludeRemoveButton];
    
    [includeControlBar addButton:includeAddButton];
    [includeControlBar addButton:includeRemoveButton];
    
    preferences = [[ACPreferences alloc] init];
    [includeTable reloadData];
    [excludeTable reloadData];
    
    autoLaunch = [ANAutoLaunch autoLaunchForDaemon];
    if ([autoLaunch bundleExistsInLaunchItems]) {
        [autoLaunchCheckbox setState:1];
    }
    
    daemonWatcher = [[ACDaemonWatcher alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(daemonStatusChanged:)
                                                 name:ACDaemonWatcherRunningChangedNotification
                                               object:daemonWatcher];
    [self daemonStatusChanged:nil];
}

- (void)includeAddPressed:(id)sender {
    [preferences addIncludePath:@""];
    [includeTable reloadData];
    [includeTable editColumn:0 row:([[preferences includePaths] count] - 1) withEvent:nil select:YES];
    [self notifyDaemonChange];
}

- (void)includeRemovePressed:(id)sender {
    [preferences removeIncludePathsAtIndexes:[includeTable selectedRowIndexes]];
    [includeTable reloadData];
    [self notifyDaemonChange];
}

- (void)excludeAddPressed:(id)sender {
    [preferences addExcludePath:@""];
    [excludeTable reloadData];
    [excludeTable editColumn:0 row:([[preferences excludePaths] count] - 1) withEvent:nil select:YES];
    [self notifyDaemonChange];
}

- (void)excludeRemovePressed:(id)sender {
    [preferences removeExcludePathsAtIndexes:[excludeTable selectedRowIndexes]];
    [excludeTable reloadData];
    [self notifyDaemonChange];
}

- (void)autoLaunchChanged:(id)sender {
    if (![autoLaunchCheckbox state]) {
        [autoLaunch removeBundleFromLaunchItems];
    } else {
        [autoLaunch addBundleToLaunchItems];
    }
}

- (IBAction)launchDaemon:(id)sender {
    if ([daemonWatcher isDaemonRunning]) {
        [daemonWatcher terminateDaemon];
        if ([daemonWatcher isDaemonRunning]) [launchButton setEnabled:NO];
    } else {
        [daemonWatcher executeDaemon];
        if (![daemonWatcher isDaemonRunning]) [launchButton setEnabled:NO];
    }
}

- (void)daemonStatusChanged:(NSNotification *)notification {
    [launchButton setEnabled:YES];
    if ([daemonWatcher isDaemonRunning]) {
        [launchButton setTitle:@"Terminate Daemon"];
    } else {
        [launchButton setTitle:@"Execute Daemon"];
    }
}

- (BOOL)notifyDaemonChange {
    [daemonWatcher tryToConnect];
    [[daemonWatcher connectedProxy] preferencesChanged];
    return YES;
}

#pragma mark - Table View -

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([notification object] == includeTable) {
        if ([[includeTable selectedRowIndexes] count] == 0) {
            [includeRemoveButton setEnabled:NO];
            [includeControlBar setNeedsDisplay:YES];
        } else {
            [includeRemoveButton setEnabled:YES];
            [includeControlBar setNeedsDisplay:YES];
        }
    } else {
        if ([[excludeTable selectedRowIndexes] count] == 0) {
            [excludeRemoveButton setEnabled:NO];
            [excludeControlBar setNeedsDisplay:YES];
        } else {
            [excludeRemoveButton setEnabled:YES];
            [excludeControlBar setNeedsDisplay:YES];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (tableView == includeTable) {
        return [[preferences includePaths] count];
    } else {
        return [[preferences excludePaths] count];
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == includeTable) {
        return [[preferences includePaths] objectAtIndex:row];
    } else {
        return [[preferences excludePaths] objectAtIndex:row];
    }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (tableView == includeTable) {
        [preferences replaceIncludePath:object atIndex:row];
    } else {
        [preferences replaceExcludePath:object atIndex:row];
    }
    [self notifyDaemonChange];
}

@end
