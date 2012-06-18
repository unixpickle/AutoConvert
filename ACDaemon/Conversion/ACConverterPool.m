//
//  ACConverterPool.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACConverterPool.h"

@implementation ACConverterPool

+ (ACConverterPool *)sharedPool {
    static ACConverterPool * pool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pool = [[ACConverterPool alloc] init];
    });
    return pool;
}

- (id)init {
    if ((self = [super init])) {
        converterClasses = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addConverterClass:(Class)converter {
    [converterClasses addObject:converter];
}

- (Class)converterClassForSourceExtension:(NSString *)ext1 destination:(NSString *)ext2 {
    for (Class object in converterClasses) {
        if ([object supportsExtension:ext1 toExtension:ext2]) return object;
    }
    return Nil;
}

- (ACConverter *)converterForFile:(NSString *)path source:(NSString *)ext1 destination:(NSString *)ext2 {
    Class class = [self converterClassForSourceExtension:ext1 destination:ext2];
    if (class) {
        return [[class alloc] initWithFile:path source:ext1 dest:ext2];
    }
    NSArray * pathsOut = nil;
    NSArray * converters = nil;
    if (![self bridgeFormat:ext1 toFormat:ext2 formats:&pathsOut converters:&converters]) return nil;
    return [[ACConverterBridge alloc] initWithFile:path formats:pathsOut converters:converters];
}

#pragma mark Bridging

- (NSString *)suggestedBridgeForInput:(NSString *)input output:(NSString *)output {
    if ([input isEqualToString:@"flac"] || [output isEqualToString:@"flac"]) {
        return @"wav";
    }
    if ([input isEqualToString:@"xm"] || [output isEqualToString:@"xm"]) {
        return @"wav";
    }
    return nil;
}

- (BOOL)bridgeFormat:(NSString *)input toFormat:(NSString *)output formats:(NSArray **)pathsOut converters:(NSArray **)classesOut {
    NSString * bridge = [self suggestedBridgeForInput:input output:output];
    if (!bridge) return NO;
    
    // go through each converter for each converter to find a pair that work with
    // the detected bridge format
    for (int i = 0; i < [converterClasses count]; i++) {
        Class sourceConverter = [converterClasses objectAtIndex:i];
        if (![sourceConverter supportsExtension:input toExtension:bridge]) continue;
        for (int j = 0; j < [converterClasses count]; j++) {
            Class destConverter = [converterClasses objectAtIndex:j];
            if ([destConverter supportsExtension:bridge toExtension:output]) {
                if (pathsOut) *pathsOut = [NSArray arrayWithObjects:input, bridge, output, nil];
                if (classesOut) *classesOut = [NSArray arrayWithObjects:sourceConverter, destConverter, nil];
                return YES;
            }
        }
    }
    return NO;
}

@end
