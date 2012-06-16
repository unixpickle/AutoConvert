//
//  ACDaemonInterface.h
//  AutoConvert
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ACDaemonInterface <NSObject>

- (void)preferencesChanged;
- (void)terminate;

@end
