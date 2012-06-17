//
//  ACConverterBridge.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACConverterBridge.h"

@implementation ACConverterBridge

- (id)initWithFile:(NSString *)aFile formats:(NSArray *)steps converters:(NSArray *)classes {
    if ((self = [super init])) {
        file = aFile;
        destinationFormats = steps;
        converterClasses = classes;
        sourceExtension = [steps objectAtIndex:0];
        destExtension = [steps lastObject];
    }
    return self;
}

- (void)convertSynchronously:(ACConverterCallback)callback {
    for (int i = 0; i < [converterClasses count]; i++) {
        if ([[NSThread currentThread] isCancelled]) {
            [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
            return;
        }
        Class class = [converterClasses objectAtIndex:i];
        NSString * theDest = [destinationFormats objectAtIndex:(i + 1)];
        NSString * theSource = [destinationFormats objectAtIndex:i];
        tempFile = [self createTempPath:theDest];
        if (!tempFile) {
            callback(ACConverterCallbackTypeError, 0, [NSError errorWithDomain:@"ACConverterBridge"
                                                                          code:1
                                                                      userInfo:nil]);
            return;
        }
        ACConverter * converter = [[class alloc] initWithFile:tempFile source:theSource dest:theDest];
        if (!converter) {
            callback(ACConverterCallbackTypeError, 0, [NSError errorWithDomain:@"ACConverterBridge"
                                                                          code:2
                                                                      userInfo:nil]);
            [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
            return;
        }
        __block BOOL hasFailed = NO;
        [converter convertSynchronously:^(ACConverterCallbackType type, double progress, NSError * error) {
            if (type == ACConverterCallbackTypeError) {
                callback(ACConverterCallbackTypeError, 0, error);
                [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
                hasFailed = YES;
            } else if (type == ACConverterCallbackTypeProgress) {
                float emulatedProgress = progress / (float)[converterClasses count] + ((float)i / (float)[converterClasses count]);
                callback(ACConverterCallbackTypeProgress, emulatedProgress, nil);
            }
        }];
        if (hasFailed) return;
    }
    
    if ([[NSThread currentThread] isCancelled]) {
        [[NSFileManager defaultManager] removeItemAtPath:tempFile error:nil];
        return;
    }
    
    NSError * placeError = nil;
    if (![self placeTempFile:&placeError]) {
        callback(ACConverterCallbackTypeError, 0, placeError);
    }
    
    callback(ACConverterCallbackTypeDone, 0, nil);
}

- (NSString *)createTempPath:(NSString *)extension {
    NSString * tempBase = [NSTemporaryDirectory() stringByAppendingPathComponent:@"com.aqnichol.acdaemon.temp"];
    for (int i = 1; i < 1000; i++) {
        NSString * testTemp = [tempBase stringByAppendingFormat:@".%d.%@", i, extension];
        if (![[NSFileManager defaultManager] fileExistsAtPath:testTemp]) {
            if (!tempFile) {
                NSError * error = nil;
                if (![[NSFileManager defaultManager] createSymbolicLinkAtPath:testTemp
                                                          withDestinationPath:self.file
                                                                        error:&error]) {
                    NSLog(@"Link error: %@", error);
                    return nil;
                }
            } else {
                if (![[NSFileManager defaultManager] moveItemAtPath:tempFile
                                                             toPath:testTemp
                                                              error:nil]) {
                    return nil;
                }
            }
            return testTemp;
        }
    }
    return nil;
}

@end
