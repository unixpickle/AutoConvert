//
//  ACConverter.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACConverter.h"

@interface ACConverter (Private)

- (void)runAsyncWithSync;
- (void)informDelegateDone;
- (void)informDelegateError:(NSError *)error;
- (void)informDelegateProgress:(float)progress;

@end

@implementation ACConverter

@synthesize file;
@synthesize sourceExtension;
@synthesize destExtension;
@synthesize tempFile;
@synthesize delegate;

+ (BOOL)supportsExtension:(NSString *)oldExt toExtension:(NSString *)newExt {
    return NO;
}

- (id)initWithFile:(NSString *)aFile source:(NSString *)oldExt dest:(NSString *)newExt {
    if ((self = [super init])) {
        file = aFile;
        sourceExtension = oldExt;
        destExtension = newExt;
        NSString * tempBase = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.aqnichol.acdaemon.temp"];
        for (int i = 1; i < 1000; i++) {
            NSString * testTemp = [tempBase stringByAppendingFormat:@".%d", i];
            if (![[NSFileManager defaultManager] fileExistsAtPath:testTemp]) {
                if (![[NSFileManager defaultManager] createFileAtPath:testTemp contents:[NSData data] attributes:nil]) {
                    return nil;
                }
                tempFile = testTemp;
                break;
            }
        }
        if (!tempFile) return nil;
    }
    return self;
}

- (void)beginConverting {
    if (backgroundThread) return;
    mainQueue = dispatch_get_current_queue();
    backgroundThread = [[NSThread alloc] initWithTarget:self selector:@selector(runAsyncWithSync) object:nil];
    [backgroundThread start];
}

- (void)cancelConverting {
    [backgroundThread cancel];
    backgroundThread = nil;
}

- (BOOL)placeTempFile:(NSError **)error {
    if (![[NSFileManager defaultManager] removeItemAtPath:file error:error]) return NO;
    if (![[NSFileManager defaultManager] moveItemAtPath:tempFile toPath:file error:error]) return NO;
    tempFile = nil;
    return YES;
}

- (void)convertSynchronously:(ACConverterCallback)callback {
    NSDictionary * info = [NSDictionary dictionaryWithObject:@"ACConverter must be sub-classed"
                                                      forKey:NSLocalizedDescriptionKey];
    NSError * error = [NSError errorWithDomain:@"ACConverter" code:1 userInfo:info];
    callback(ACConverterCallbackTypeError, 0, error);
}

- (NSString *)conversionTitle {
    return [NSString stringWithFormat:@"Converting %@ from \"%@\"",
            [file lastPathComponent], sourceExtension];
}

#pragma mark - Private -

- (void)runAsyncWithSync {
    @autoreleasepool {
        __block BOOL reportedDone = NO;
        [self convertSynchronously:^(ACConverterCallbackType type, double progress, NSError *error) {
            if ([[NSThread currentThread] isCancelled]) return;
            if (type == ACConverterCallbackTypeDone) {
                dispatch_async(mainQueue, ^{
                    [self informDelegateDone];
                });
                reportedDone = YES;
            } else if (type == ACConverterCallbackTypeError) {
                dispatch_async(mainQueue, ^{
                    [self informDelegateError:error];
                });
                reportedDone = YES;
            } else if (type == ACConverterCallbackTypeProgress) {
                dispatch_async(mainQueue, ^{
                    [self informDelegateProgress:progress];
                });
            }
        }];
        if (!reportedDone) {
            dispatch_async(mainQueue, ^{
                [self informDelegateDone];
            });
        }
        dispatch_async(mainQueue, ^{
            backgroundThread = nil;
            mainQueue = nil;
            if (tempFile) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
                    [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
                }
                tempFile = nil;
            }
        });
    }
}

- (void)informDelegateDone {
    if ([delegate respondsToSelector:@selector(converterFinished:)]) {
        [delegate converterFinished:self];
    }
}

- (void)informDelegateError:(NSError *)error {
    if ([delegate respondsToSelector:@selector(converter:failedWithError:)]) {
        [delegate converter:self failedWithError:error];
    }
}

- (void)informDelegateProgress:(float)progress {
    if ([delegate respondsToSelector:@selector(converter:progressUpdate:)]) {
        [delegate converter:self progressUpdate:progress];
    }
}

- (void)dealloc {
    if (tempFile) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempFile]) {
            [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
        }
    }
}

@end
