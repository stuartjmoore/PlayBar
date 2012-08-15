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
    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    
    self.statusItem.image = [NSImage imageNamed:@"statusBarIcon"];
    self.statusItem.menu = self.statusMenu;
    
    [self.statusItem setTarget:self];
    [self.statusItem setAction:@selector(click:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieRateChanged:)
                                                 name:QTMovieRateDidChangeNotification
                                               object:self.player];
    
    SMStatusView *view = [[SMStatusView alloc] initWithFrame:NSMakeRect(0, 0, 22, NSStatusBar.systemStatusBar.thickness)];
    view.statusItem = self.statusItem;
    view.delegate = self;
    self.statusItem.view = view;
    
    self.episodes = [NSMutableArray array];
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
    /*
    NSLog(@"%@", self.player.commonMetadata);
    NSLog(@"%@", self.player.availableMetadataFormats);
    NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatID3Metadata"]);
    NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatQuickTimeMetadata"]);
    NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatQuickTimeUserData"]);
    NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatiTunesMetadata"]);
    */
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
            [self addURL:panel.URL];
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
        [self addURL:[NSURL URLWithString:self.URLField.stringValue]];
    }
}

- (void)addURL:(NSURL*)url
{
    QTMovie *file = [QTMovie movieWithURL:url error:nil];
    
    if(file)
    {
        self.player = file;
        [self.player autoplay];
        
        [self.episodes addObject:url];
        NSLog(@"%@", self.episodes);
    }
}

- (BOOL)togglePopover
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
    
    return self.popover.isVisible;
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

- (IBAction)nextEpisode:(id)sender
{
}

- (IBAction)toggleList:(id)sender
{
    NSSize screenSize = [[self.popover screen] frame].size;
    NSRect frame = self.popover.frame;
    
    if(frame.size.height > self.popover.minSize.height)
        frame.size.height = self.popover.minSize.height;
    else
        frame.size.height += 200;
    
    frame.origin.y = screenSize.height - 22 - frame.size.height;
    
    [self.popover setFrame:frame display:YES animate:YES];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
    return self.episodes.count;
}

- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)rowIndex
{
    if([tableColumn.identifier isEqualToString:@"title"])
    {
        return [self.episodes objectAtIndex:rowIndex];
    }
    else if([tableColumn.identifier isEqualToString:@"isPlaying"])
    {
        NSURL *url = [self.episodes objectAtIndex:rowIndex];
        NSURL *playingURL = [self.player attributeForKey:@"QTMovieURLAttribute"];
        
        if([url isEqualTo:playingURL])
            return @"✓";
    }
    
    return nil;
}

@end
