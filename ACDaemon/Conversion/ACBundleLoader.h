//
//  ACBundleLoader.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACConverterPool.h"

@interface ACBundleLoader : NSObject {
    NSArray * bundlePaths;
}

+ (void)loadAllPlugIns;

- (id)initWithContainerBundle:(NSBundle *)currentBundle;
- (void)loadBundles;
- (BOOL)loadBundle:(NSBundle *)bundle;

@end
