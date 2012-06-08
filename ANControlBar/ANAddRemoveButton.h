//
//  ANAddButton.h
//  ControlBar
//
//  Created by Alex Nichol on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANBarButton.h"

@interface ANAddRemoveButton : ANBarButton {
    BOOL addButton;
}

@property (readwrite) BOOL addButton;

@end
