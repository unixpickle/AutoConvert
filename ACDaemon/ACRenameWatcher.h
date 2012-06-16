//
//  ACRenameWatcher.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACPathHistory.h"

@class ACRenameWatcher;

@protocol ACRenameWatcherDelegate <NSObject>

@optional
- (void)renameWatcher:(ACRenameWatcher *)sender path:(NSString *)oldPath movedTo:(NSString *)newPath;

@end

@interface ACRenameWatcher : NSObject {
    NSString * path;
    FSEventStreamRef eventStream;
    __weak id<ACRenameWatcherDelegate> delegate;
    ACPathHistory * pathHistory;
}

@property (nonatomic, weak) id<ACRenameWatcherDelegate> delegate;

- (id)initWithPath:(NSString *)aPath;
- (void)startWatching;
- (void)stopWatching;

@end
