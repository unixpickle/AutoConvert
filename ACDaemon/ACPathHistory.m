//
//  ACPathHistory.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACPathHistory.h"

@implementation ACPathHistory

- (id)init {
    if ((self = [super init])) {
        eventIDs = [[NSMutableArray alloc] init];
        eventPaths = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)pathForEventID:(FSEventStreamEventId)eventID {
    for (NSInteger index = 0; index < [eventIDs count]; index++) {
        if ([[eventIDs objectAtIndex:index] unsignedLongLongValue] == eventID) {
            return [eventPaths objectAtIndex:index];
        }
    }
    return nil;
}

- (void)setPath:(NSString *)path forEventID:(FSEventStreamEventId)eventID {
    for (NSInteger index = 0; index < [eventIDs count]; index++) {
        if ([[eventIDs objectAtIndex:index] unsignedLongLongValue] == eventID) {
            [eventPaths replaceObjectAtIndex:index withObject:path];
            return;
        }
    }
    [eventIDs addObject:[NSNumber numberWithUnsignedLongLong:eventID]];
    [eventPaths addObject:path];
}

- (void)removePathForEventID:(FSEventStreamEventId)eventID {
    for (NSInteger index = 0; index < [eventIDs count]; index++) {
        if ([[eventIDs objectAtIndex:index] unsignedLongLongValue] == eventID) {
            [eventPaths removeObjectAtIndex:index];
            [eventIDs removeObjectAtIndex:index];
            return;
        }
    }
}

- (void)deleteOldEvents:(NSUInteger)maxCount {
    while ([eventIDs count] > maxCount) {
        [eventPaths removeObjectAtIndex:0];
        [eventIDs removeObjectAtIndex:0];
    }
}

@end
