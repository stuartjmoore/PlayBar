//
//  SMAppDelegate.m
//  PlayBar
//
//  Created by Stuart Moore on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMAppDelegate.h"

@implementation SMAppDelegate

@synthesize popover = _popover;

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    myStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    //[myStatusItem setHighlightMode:YES];
    [myStatusItem setToolTip:@"PlayBar\nWeekend Confirmed - Ep. 125 - 08/10/2012"];
    
    //[myStatusItem setTitle:@"Weekend Confirmed - Ep. 125 - 08/10/2012"];
    [myStatusItem setImage:[NSImage imageNamed:@"statusBarItemImage.png"]];
    //[myStatusItem setMenu:myStatusMenu];
    
    [myStatusItem setTarget:self];
    [myStatusItem setAction:@selector(click:)];
    [myStatusItem setDoubleAction:@selector(doubleClick:)];
}

- (void)click:(id)sender
{
    NSLog(@"click %@", sender);
    
    NSRect frame = [[[NSApp currentEvent] window] frame];
    NSSize screenSize = [[self.popover screen] frame].size;
    
    if(self.popover.isVisible)
    {
        [self.popover close];
    }
    else
    {
        frame.origin.y -= self.popover.frame.size.height;
        frame.origin.x += (frame.size.width - self.popover.frame.size.width)/2;
        
        if(screenSize.width < frame.origin.x + self.popover.frame.size.width)
            frame.origin.x = screenSize.width - self.popover.frame.size.width - 10;
        
        [self.popover setFrameOrigin:frame.origin];
        
        [self.popover makeKeyAndOrderFront:self];
        [self.popover setIsVisible:YES];
    }
}
- (void)doubleClick:(id)sender
{
    NSLog(@"doubleClick %@", sender);
}

@end
