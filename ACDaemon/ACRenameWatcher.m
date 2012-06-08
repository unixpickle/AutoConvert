//
//  ACRenameWatcher.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACRenameWatcher.h"

static void ACRenameWatcherCallback(ConstFSEventStreamRef streamRef,
                                    void * clientCallBackInfo,
                                    size_t numEvents,
                                    void * eventPaths,
                                    const FSEventStreamEventFlags eventFlags[],
                                    const FSEventStreamEventId eventIds[]);

@interface ACRenameWatcher (Private)

- (void)pathMoved:(NSString *)old toPath:(NSString *)new;

@end

@implementation ACRenameWatcher

@synthesize delegate;

- (id)initWithPath:(NSString *)aPath {
    if ((self = [super init])) {
        path = aPath;
    }
    return self;
}

- (void)startWatching {
    if (eventStream) return;
    CFStringRef string = (__bridge_retained CFStringRef)path;
    CFArrayRef pathsToWatch = CFArrayCreate(NULL, (const void **)&string, 1, NULL);
    FSEventStreamContext context;
    bzero(&context, sizeof(context));
    context.info = (__bridge void *)self;
    eventStream = FSEventStreamCreate(NULL,
                                      &ACRenameWatcherCallback,
                                      &context,
                                      pathsToWatch,
                                      kFSEventStreamEventIdSinceNow,
                                      3,
                                      kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagNoDefer);
    FSEventStreamScheduleWithRunLoop(eventStream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(eventStream);
    CFRelease(pathsToWatch);
}

- (void)stopWatching {
    FSEventStreamStop(eventStream);
    FSEventStreamInvalidate(eventStream);
    FSEventStreamRelease(eventStream);
    eventStream = NULL;
}

- (void)pathMoved:(NSString *)old toPath:(NSString *)new {
    if ([delegate respondsToSelector:@selector(renameWatcher:path:movedTo:)]) {
        [delegate renameWatcher:self path:old movedTo:new];
    }
}

@end

static void ACRenameWatcherCallback(ConstFSEventStreamRef streamRef,
                                    void * clientCallBackInfo,
                                    size_t numEvents,
                                    void * eventPaths,
                                    const FSEventStreamEventFlags eventFlags[],
                                    const FSEventStreamEventId eventIds[]) {
    NSMutableDictionary * pathsForIds = [NSMutableDictionary dictionary];
    
    ACRenameWatcher * watcher = (__bridge ACRenameWatcher *)clientCallBackInfo;
    for (size_t i = 0; i < numEvents; i++) {
        if ((eventFlags[i] & kFSEventStreamEventFlagItemRenamed) == 0) {
            continue;
        }
        NSString * path = [NSString stringWithUTF8String:((char **)eventPaths)[i]];
        NSNumber * testID = [NSNumber numberWithUnsignedLongLong:(eventIds[i] - 1)];
        if ([pathsForIds objectForKey:testID]) {
            NSString * oldPath = [pathsForIds objectForKey:testID];
            [watcher pathMoved:oldPath toPath:path];
        }
        [pathsForIds setObject:path
                        forKey:[NSNumber numberWithUnsignedLongLong:eventIds[i]]];
    }
}
