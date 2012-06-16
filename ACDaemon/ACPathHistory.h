//
//  ACPathHistory.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACPathHistory : NSObject {
    NSMutableArray * eventIDs;
    NSMutableArray * eventPaths;
}

- (NSString *)pathForEventID:(FSEventStreamEventId)eventID;
- (void)setPath:(NSString *)path forEventID:(FSEventStreamEventId)eventID;
- (void)removePathForEventID:(FSEventStreamEventId)eventID;

- (void)deleteOldEvents:(NSUInteger)maxCount;

@end
