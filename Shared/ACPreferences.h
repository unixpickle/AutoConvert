//
//  ACPreferences.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACPreferences : NSObject {
    NSMutableDictionary * dictionary;
    NSString * savePath;
}

- (BOOL)boolForKey:(NSString *)key initial:(BOOL)def;
- (void)setBool:(BOOL)flag forKey:(NSString *)key;

- (id)objectForKey:(NSString *)key initial:(id)object;
- (void)setObject:(id)object forKey:(NSString *)key;

- (NSArray *)includePaths;
- (NSArray *)excludePaths;
- (void)addIncludePath:(NSString *)path;
- (void)addExcludePath:(NSString *)path;
- (void)removeIncludePath:(NSString *)path;
- (void)removeExcludePath:(NSString *)path;
- (void)removeIncludePathsAtIndexes:(NSIndexSet *)indexes;
- (void)removeExcludePathsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceIncludePath:(NSString *)path atIndex:(NSUInteger)index;
- (void)replaceExcludePath:(NSString *)path atIndex:(NSUInteger)index;

- (void)reloadFromFile;

@end
