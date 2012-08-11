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
@synthesize popover = _popover;
@synthesize player = _player, timer = _timer;
@synthesize timeElapsedLabel, timeRemainingLabel;
@synthesize titleLabel = _titleLabel, albumLabel = _albumLabel, artistLabel = _artistLabel;
@synthesize seekbar = _seekbar, albumArtView = _albumArtView, playPauseButton = _playPauseButton;

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    [self.statusItem setToolTip:@"PlayBar\nWeekend Confirmed - Ep. 125 - 08/10/2012"];
    
    [self.statusItem setImage:[NSImage imageNamed:@"statusBarItemImage.png"]];
    
    [self.statusItem setTarget:self];
    [self.statusItem setAction:@selector(click:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieRateChanged:)
                                                 name:QTMovieRateDidChangeNotification
                                               object:self.player];
}

- (void)movieRateChanged:(NSNotification*)notification
{
    if(self.player.rate)
    {
        self.playPauseButton.title = @"Pause";
        
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateSlider:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:(NSString*)kCFRunLoopCommonModes];
    }
    else
    {
        self.playPauseButton.title = @"Play";
        
        [self.timer invalidate];
    }
    
    self.seekbar.minValue = 0;
    self.seekbar.maxValue = self.player.duration.timeValue;
    self.seekbar.floatValue = self.player.currentTime.timeValue;
    
    self.timeElapsedLabel.stringValue = [NSString stringWithFormat:@"%lld", self.player.currentTime.timeValue];
    self.timeRemainingLabel.stringValue = [NSString stringWithFormat:@"%lld", self.player.duration.timeValue];
    self.albumArtView.image = self.player.posterImage;
    /*
    NSLog(@"%@", self.player.commonMetadata);
    NSLog(@"%@", self.player.availableMetadataFormats);
    */
    for(QTMetadataItem *item in self.player.commonMetadata)
    {
        if([(NSString*)item.key isEqualToString:@"title"])
            self.titleLabel.stringValue = item.stringValue;
        else if([(NSString*)item.key isEqualToString:@"albumName"])
            self.albumLabel.stringValue = item.stringValue;
        else if([(NSString*)item.key isEqualToString:@"artist"])
            self.artistLabel.stringValue = item.stringValue;
    }
}

- (void)updateSlider:(id)timer
{
    self.seekbar.floatValue = self.player.currentTime.timeValue;
    
    self.timeElapsedLabel.stringValue = [NSString stringWithFormat:@"%lld", self.player.currentTime.timeValue];
    self.timeRemainingLabel.stringValue = [NSString stringWithFormat:@"%lld", self.player.duration.timeValue];
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

@end
