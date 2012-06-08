//
//  ACPath.m
//  AutoConvert
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ACPath.h"

@implementation ACPath

@synthesize components;

- (id)initWithString:(NSString *)posixPath {
    if ((self = [super init])) {
        components = [[posixPath stringByStandardizingPath] pathComponents];
    }
    return self;
}

- (BOOL)hasPrefix:(ACPath *)path {
    if ([[path components] count] > [components count]) return NO;
    for (int i = 0; i < [[path components] count]; i++) {
        NSString * ourComp = [components objectAtIndex:i];
        NSString * comp = [[path components] objectAtIndex:i];
        if (![ourComp isEqualToString:comp]) {
            return NO;
        }
    }
    return YES;
}

@end
