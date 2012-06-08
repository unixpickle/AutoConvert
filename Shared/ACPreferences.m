//
//  ACPreferences.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACPreferences.h"

@interface ACPreferences (Private)

- (BOOL)generateSavePath;
- (void)save;
- (void)load;

@end

@implementation ACPreferences

- (id)init {
    if ((self = [super init])) {
        if (![self generateSavePath]) {
            return nil;
        }
        [self load];
    }
    return self;
}

- (BOOL)boolForKey:(NSString *)key initial:(BOOL)def {
    NSNumber * value = [dictionary objectForKey:key];
    if (!value) {
        [self setBool:def forKey:key];
        return def;
    }
    return [value boolValue];
}

- (void)setBool:(BOOL)flag forKey:(NSString *)key {
    [dictionary setObject:[NSNumber numberWithBool:flag] forKey:key];
    [self save];
}

- (id)objectForKey:(NSString *)key initial:(id)object {
    id value = [dictionary objectForKey:key];
    if (!value) {
        if (object) [self setObject:object forKey:key];
        return object;
    }
    return value;
}

- (void)setObject:(id)object forKey:(NSString *)key {
    [dictionary setObject:object forKey:key];
    [self save];
}

#pragma mark - Specialized -

- (NSArray *)includePaths {
    return [self objectForKey:@"include" initial:[NSArray arrayWithObject:@"/"]];
}

- (NSArray *)excludePaths {
    return [self objectForKey:@"exclude" initial:[NSArray array]];
}

- (void)addIncludePath:(NSString *)path {
    NSArray * include = [self includePaths];
    [self setObject:[include arrayByAddingObject:path] forKey:@"include"];
}

- (void)addExcludePath:(NSString *)path {
    NSArray * exclude = [self excludePaths];
    [self setObject:[exclude arrayByAddingObject:path] forKey:@"exclude"];
}

- (void)removeIncludePath:(NSString *)path {
    NSMutableArray * include = [[self includePaths] mutableCopy];
    [include removeObject:path];
    [self setObject:include forKey:@"include"];
}

- (void)removeExcludePath:(NSString *)path {
    NSMutableArray * exclude = [[self excludePaths] mutableCopy];
    [exclude removeObject:path];
    [self setObject:exclude forKey:@"exclude"];
}

- (void)removeIncludePathsAtIndexes:(NSIndexSet *)indexes {
    NSMutableArray * include = [[self includePaths] mutableCopy];
    [indexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL * stop) {
        [include removeObjectAtIndex:idx];
    }];
    [self setObject:include forKey:@"include"];
}

- (void)removeExcludePathsAtIndexes:(NSIndexSet *)indexes {
    NSMutableArray * exclude = [[self excludePaths] mutableCopy];
    [indexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL * stop) {
        [exclude removeObjectAtIndex:idx];
    }];
    [self setObject:exclude forKey:@"exclude"];
}

- (void)replaceIncludePath:(NSString *)path atIndex:(NSUInteger)index {
    NSMutableArray * include = [[self includePaths] mutableCopy];
    [include replaceObjectAtIndex:index withObject:path];
    [self setObject:include forKey:@"include"];
}

- (void)replaceExcludePath:(NSString *)path atIndex:(NSUInteger)index {
    NSMutableArray * exclude = [[self excludePaths] mutableCopy];
    [exclude replaceObjectAtIndex:index withObject:path];
    [self setObject:exclude forKey:@"exclude"];
}

- (void)reloadFromFile {
    [self load];
}

#pragma mark - Private -

- (BOOL)generateSavePath {
    NSString * appSupport = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Application Support"];
    NSString * appDirectory = [appSupport stringByAppendingPathComponent:@"AutoConvert"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:appDirectory]) {
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:appDirectory
                                                withIntermediateDirectories:NO
                                                                 attributes:nil
                                                                      error:nil];
        if (!result) return NO;
    }
    savePath = [appDirectory stringByAppendingPathComponent:@"save.plist"];
    return YES;
}

- (void)save {
    [dictionary writeToFile:savePath atomically:YES];
}

- (void)load {
    dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:savePath];
    if (!dictionary) {
        dictionary = [[NSMutableDictionary alloc] init];
    }
}

@end
