//
//  ACConverterPool.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACConverterBridge.h"

@interface ACConverterPool : NSObject {
    NSMutableArray * converterClasses;
}

+ (ACConverterPool *)sharedPool;

- (void)addConverterClass:(Class)converter;
- (Class)converterClassForSourceExtension:(NSString *)ext1 destination:(NSString *)ext2;
- (ACConverter *)converterForFile:(NSString *)path source:(NSString *)ext1 destination:(NSString *)ext2;

- (NSString *)suggestedBridgeForInput:(NSString *)input output:(NSString *)output;
- (BOOL)bridgeFormat:(NSString *)input toFormat:(NSString *)output formats:(NSArray **)pathsOut converters:(NSArray **)classesOut;

@end
