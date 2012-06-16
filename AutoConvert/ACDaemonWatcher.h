//
//  ACDaemonWatcher.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACDaemonInterface.h"

#define ACDaemonWatcherRunningChangedNotification @"ACDaemonWatcherRunningChangedNotification"

@interface ACDaemonWatcher : NSObject {
    NSConnection * activeConnection;
    NSTimer * reconnectTimer;
}

- (void)tryToConnect;

- (BOOL)isDaemonRunning;
- (id<ACDaemonInterface>)connectedProxy;

- (void)executeDaemon;
- (void)terminateDaemon;

@end
