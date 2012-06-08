//
//  ACPath.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACPath : NSObject {
    NSArray * components;
}

@property (readonly) NSArray * components;

- (id)initWithString:(NSString *)posixPath;
- (BOOL)hasPrefix:(ACPath *)path;

@end
