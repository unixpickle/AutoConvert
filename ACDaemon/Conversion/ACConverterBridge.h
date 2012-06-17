//
//  ACConverterBridge.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <ACPlugIn/ACConverter.h>

@interface ACConverterBridge : ACConverter {
    NSArray * converterClasses;
    NSArray * destinationFormats;
}

- (id)initWithFile:(NSString *)aFile formats:(NSArray *)steps converters:(NSArray *)classes;
- (NSString *)createTempPath:(NSString *)extension;

@end
