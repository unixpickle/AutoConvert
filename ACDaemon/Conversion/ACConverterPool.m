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
    if (!class) return nil;
    return [[class alloc] initWithFile:path source:ext1 dest:ext2];
}

@end
