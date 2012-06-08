//
//  ANAutoLaunch.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ANAutoLaunch : NSObject {
    NSString * bundlePath;
}

@property (readonly) NSString * bundlePath;

+ (ANAutoLaunch *)autoLaunchForDaemon;
- (id)initWithBundlePath:(NSString *)appBundle;

- (BOOL)bundleExistsInLaunchItems;
- (void)addBundleToLaunchItems;
- (void)removeBundleFromLaunchItems;

@end
