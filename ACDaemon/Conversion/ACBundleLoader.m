//
//  ACBundleLoader.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACBundleLoader.h"

@implementation ACBundleLoader

+ (void)loadAllPlugIns {
    ACBundleLoader * loader = [[ACBundleLoader alloc] initWithContainerBundle:[NSBundle mainBundle]];
    [loader loadBundles];
}

- (id)initWithContainerBundle:(NSBundle *)currentBundle {
    if ((self = [super init])) {
        NSString * plugIns = [currentBundle builtInPlugInsPath];
        NSArray * names = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:plugIns error:nil];
        
        NSMutableArray * fullPaths = [NSMutableArray array];
        for (NSString * name in names) {
            [fullPaths addObject:[plugIns stringByAppendingPathComponent:name]];
        }
        bundlePaths = [[NSArray alloc] initWithArray:fullPaths];
    }
    return self;
}

- (void)loadBundles {
    for (NSString * path in bundlePaths) {
        NSBundle * bundle = [[NSBundle alloc] initWithPath:path];
        [self loadBundle:bundle];
    }
}

- (BOOL)loadBundle:(NSBundle *)bundle {
    Class baseClass = [bundle principalClass];
    if (baseClass == Nil) return NO;
    [[ACConverterPool sharedPool] addConverterClass:baseClass];
    return YES;
}

@end
