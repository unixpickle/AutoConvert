//
//  ACPathMatcher.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACPathMatcher.h"

@implementation ACPathMatcher

- (id)initWithInclude:(NSArray *)incStrs exclude:(NSArray *)exStrs {
    if ((self = [super init])) {
        NSMutableArray * mIncludes = [[NSMutableArray alloc] initWithCapacity:[incStrs count]];
        NSMutableArray * mExcludes = [[NSMutableArray alloc] initWithCapacity:[exStrs count]];
        for (NSString * pathStr in incStrs) {
            ACPath * path = [[ACPath alloc] initWithString:pathStr];
            [mIncludes addObject:path];
        }
        for (NSString * pathStr in exStrs) {
            ACPath * path = [[ACPath alloc] initWithString:pathStr];
            [mExcludes addObject:path];
        }
        includes = [mIncludes copy];
        excludes = [mExcludes copy];
    }
    return self;
}

- (BOOL)testPathString:(NSString *)aPosixPath {
    NSInteger deepestInclude = 0;
    NSInteger deepestExclude = 0;
    ACPath * path = [[ACPath alloc] initWithString:aPosixPath];
    for (ACPath * include in includes) {
        if ([path hasPrefix:include]) {
            deepestInclude = MAX(deepestInclude, [[include components] count]);
        }
    }
    for (ACPath * exclude in excludes) {
        if ([path hasPrefix:exclude]) {
            deepestExclude = MAX(deepestExclude, [[exclude components] count]);
        }
    }
    return (deepestInclude > deepestExclude);
}

@end
