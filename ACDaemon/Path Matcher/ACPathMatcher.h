//
//  ACPathMatcher.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACPath.h"

@interface ACPathMatcher : NSObject {
    NSArray * includes;
    NSArray * excludes;
}

- (id)initWithInclude:(NSArray *)incStrs exclude:(NSArray *)exStrs;
- (BOOL)testPathString:(NSString *)aPosixPath;

@end
