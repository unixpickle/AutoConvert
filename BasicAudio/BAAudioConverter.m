//
//  BAAudioConverter.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BAAudioConverter.h"

@implementation BAAudioConverter

+ (BOOL)supportsExtension:(NSString *)oldExt toExtension:(NSString *)newExt {
    return NO;
}

- (void)convertSynchronously:(ACConverterCallback)callback {
}

@end
