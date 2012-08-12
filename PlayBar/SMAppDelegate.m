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
@synthesize popover = _popover, openURLWindow = _openURLWindow;
@synthesize URLField = _URLField;
@synthesize player = _player, timer = _timer;
@synthesize timeElapsedLabel, timeRemainingLabel;
@synthesize titleLabel = _titleLabel, albumLabel = _albumLabel, artistLabel = _artistLabel;
@synthesize seekbar = _seekbar, albumArtView = _albumArtView, playPauseButton = _playPauseButton;

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    
    [self.statusItem setImage:[NSImage imageNamed:@"statusBarItemImage.png"]];
    self.statusItem.title = @"PlayBar";
    
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
        
        [self.timer invalidate];
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateSlider:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:(NSString*)kCFRunLoopCommonModes];
    }
    else
    {
        self.playPauseButton.title = @"Play";
        
        [self.timer invalidate];
    }
    
    self.titleLabel.stringValue = @"";
    self.albumLabel.stringValue = @"";
    self.artistLabel.stringValue = @"";
    self.statusItem.toolTip = @"";
    
    self.seekbar.minValue = 0;
    self.seekbar.maxValue = self.player.duration.timeValue;
    self.seekbar.floatValue = self.player.currentTime.timeValue;
    
    self.timeElapsedLabel.stringValue = [NSString stringWithFormat:@"%lld", self.player.currentTime.timeValue];
    self.timeRemainingLabel.stringValue = [NSString stringWithFormat:@"%lld", self.player.duration.timeValue];
    self.albumArtView.image = self.player.posterImage;
    
    NSLog(@"%@", self.player.commonMetadata);
    NSLog(@"%@", self.player.availableMetadataFormats);
    NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatID3Metadata"]);
    NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatQuickTimeMetadata"]);
    NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatQuickTimeUserData"]);
    NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatiTunesMetadata"]);
    
    for(QTMetadataItem *item in self.player.commonMetadata)
    {
        //NSLog(@"%@", item.key);
        
        if([(NSString*)item.key isEqualToString:@"title"])
        {
            self.titleLabel.stringValue = item.stringValue;
            self.statusItem.toolTip = [NSString stringWithFormat:@"PlayBar\n%@", item.stringValue];
        }
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

- (IBAction)openFileDialog:(id)sender
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

- (IBAction)openURLDialog:(id)sender
{
    [NSApp beginSheet:self.openURLWindow
       modalForWindow:self.popover
        modalDelegate:self
       didEndSelector:@selector(didEndSheet:returnCode:contextInfo:)
          contextInfo:nil];
}
- (IBAction)closeURLDialog:(NSButton*)sender
{
    if([sender.title isEqualToString:@"Cancel"])
        [NSApp endSheet:self.openURLWindow returnCode:0];
    else if([sender.title isEqualToString:@"Open"])
        [NSApp endSheet:self.openURLWindow returnCode:1];
}
- (void)didEndSheet:(NSWindow*)sheet returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [sheet orderOut:self];

    if(returnCode == 1)
    {
        QTMovie *file = [QTMovie movieWithURL:[NSURL URLWithString:self.URLField.stringValue] error:nil];
        
        if(file)
        {
            self.player = file;
            [self.player autoplay];
        }
    }
}


- (IBAction)togglePlayPause:(id)sender
{
    if(self.player.rate)
        [self.player stop];
    else
        [self.player play];
}

- (IBAction)slideSeekbar:(id)sender
{
    self.player.currentTime = QTMakeTime(self.seekbar.floatValue, self.player.duration.timeScale);
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
        
        [self.popover setIsVisible:YES];
        [self.popover makeKeyAndOrderFront:self];
        [self.popover setLevel:NSScreenSaverWindowLevel];
    }
}

@end
