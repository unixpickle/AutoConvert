//
//  ACDaemonWatcher.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACDaemonWatcher.h"

@interface ACDaemonWatcher (Private)

- (void)attemptReconnect:(id)info;
- (BOOL)reconnectToDaemon;
- (void)portBecameInvalid:(NSNotification *)notification;
- (void)beginWatchingConnections;

@end

@implementation ACDaemonWatcher

- (id)init {
    if ((self = [super init])) {
        if (![self reconnectToDaemon]) {
            reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                              target:self
                                                            selector:@selector(attemptReconnect:)
                                                            userInfo:nil
                                                             repeats:YES];
        }
    }
    return self;
}

- (void)attemptReconnect:(id)info {
    if (activeConnection) return;
    if ([self reconnectToDaemon]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ACDaemonWatcherRunningChangedNotification
                                                            object:self];
    }
}

- (BOOL)reconnectToDaemon {
    activeConnection = [NSConnection connectionWithRegisteredName:@"ACDaemon" host:nil];
    if (!activeConnection) return NO;
    NSDistantObject * proxy = [activeConnection rootProxy];
    [proxy setProtocolForProxy:@protocol(ACDaemonInterface)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(portBecameInvalid:)
                                                 name:NSPortDidBecomeInvalidNotification
                                               object:[activeConnection sendPort]];
    [reconnectTimer invalidate];
    reconnectTimer = nil;
    return YES;
}

- (void)portBecameInvalid:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSPortDidBecomeInvalidNotification
                                                  object:[notification object]];
    activeConnection = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:ACDaemonWatcherRunningChangedNotification
                                                        object:self];
    [self beginWatchingConnections];
}

- (void)beginWatchingConnections {
    if (reconnectTimer) return;
    reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                      target:self
                                                    selector:@selector(attemptReconnect:)
                                                    userInfo:nil
                                                     repeats:YES];
}

#pragma mark - Current Connection -

- (BOOL)isDaemonRunning {
    return activeConnection != nil;
}

- (id<ACDaemonInterface>)connectedProxy {
    return (id)[activeConnection rootProxy];
}

#pragma mark - Daemon Control -

- (void)tryToConnect {
    if (!activeConnection) [self reconnectToDaemon];
}

- (void)executeDaemon {
    if (activeConnection) return;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"ACDaemon" ofType:@"app"];
    NSString * execPath = [path stringByAppendingPathComponent:@"Contents/MacOS/ACDaemon"];
    const char * execPathC = [execPath UTF8String];
    int i = fork();
    if (i == 0) {
        signal(SIGHUP, SIG_IGN);
        char * args[2] = {(char *)execPathC, NULL};
        execvp(execPathC, args);
    }
    [self performSelector:@selector(attemptReconnect:) withObject:self afterDelay:0.5];
}

- (void)terminateDaemon {
    if (!activeConnection) return;
    [[self connectedProxy] terminate];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSPortDidBecomeInvalidNotification
                                                  object:nil];
    activeConnection = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:ACDaemonWatcherRunningChangedNotification
                                                        object:self];
    [self beginWatchingConnections];
}

@end
