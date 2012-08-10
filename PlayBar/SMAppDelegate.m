//
//  SMAppDelegate.m
//  PlayBar
//
//  Created by Stuart Moore on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMAppDelegate.h"

@implementation SMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    myStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [myStatusItem setHighlightMode:YES];
    
    //[myStatusItem setTitle:@"Weekend Confirmed - Ep. 125 - 08/10/2012"];
    [myStatusItem setImage:[NSImage imageNamed:@"statusBarItemImage.png"]];
    [myStatusItem setMenu:myStatusMenu];
}
@end
