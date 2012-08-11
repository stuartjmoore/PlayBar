//
//  SMAppDelegate.m
//  PlayBar
//
//  Created by Stuart Moore on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMAppDelegate.h"

@implementation SMAppDelegate

@synthesize statusItem = _statusItem, statusMenu = _statusMenu;
@synthesize popover = _popover, player = _player;

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setToolTip:@"PlayBar\nWeekend Confirmed - Ep. 125 - 08/10/2012"];
    
    [self.statusItem setImage:[NSImage imageNamed:@"statusBarItemImage.png"]];
    
    [self.statusItem setTarget:self];
    [self.statusItem setAction:@selector(click:)];
    [self.statusItem setDoubleAction:@selector(doubleClick:)];
    
    /*QTMovie *file = [QTMovie movieWithURL:[NSURL URLWithString:@"http://d.ahoy.co/redirect.mp3/fly.5by5.tv/audio/broadcasts/buildanalyze/2012/buildanalyze-089.mp3"] error:nil];
    if(file)
    {
        self.player = file;
        [self.player autoplay];
    }*/
}

- (IBAction)openFile:(id)sender
{
    NSOpenPanel *panel;
    
    panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"mp3"]];

    [panel beginSheetModalForWindow:self.popover completionHandler:^(NSInteger result)
    {
        if(result == NSFileHandlingPanelOKButton)
        {
            QTMovie *file = [QTMovie movieWithURL:panel.URL error:nil];
            
            if(file)
            {
                self.player = file;
                [self.player autoplay];
            }
        }
    }];
}

- (IBAction)togglePlayPause:(id)sender
{
    if(self.player.rate)
        [self.player stop];
    else
        [self.player play];
}

- (void)click:(id)sender
{
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
}

@end
