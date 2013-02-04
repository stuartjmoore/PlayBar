//
//  SMAppDelegate.m
//  PlayBar
//
//  Created by Stuart Moore on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SMAppDelegate.h"

@implementation SMAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification*)notification
{
    self.episodes = [NSMutableArray array];
    
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (BOOL)application:(NSApplication*)application openFile:(NSString*)filename
{
    NSURL *url = [NSURL fileURLWithPath:filename];
    [self addURL:url];
    
    return YES;
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSURL *url = [NSURL URLWithString:urlString];
    [self addURL:url];
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification
{
    [self.episodeList setDoubleAction:@selector(doubleClickOnTableView:)];
    
    self.statusItem = [NSStatusBar.systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    [self.statusItem setHighlightMode:YES];
    
    self.statusItem.image = [NSImage imageNamed:@"statusBarIcon"];
    self.statusItem.menu = self.statusMenu;
    
    [self.statusItem setTarget:self];
    [self.statusItem setAction:@selector(click:)];
    
    SMStatusView *statusView = [[SMStatusView alloc] initWithFrame:NSMakeRect(0, 0, 22, NSStatusBar.systemStatusBar.thickness)];
    statusView.image = [NSImage imageNamed:@"statusBarIcon"];
    statusView.statusItem = self.statusItem;
    statusView.delegate = self;
    self.statusItem.view = statusView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieLoaded:)
                                                 name:QTMovieLoadStateDidChangeNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieRateChanged:)
                                                 name:QTMovieRateDidChangeNotification
                                               object:self.player];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieEnded:)
                                                 name:QTMovieDidEndNotification
                                               object:self.player];
}

#pragma mark - QTNotifications

- (void)movieLoaded:(NSNotification*)notification
{
    NSLog(@"%@", notification);
    NSLog(@"%@", [self.player attributeForKey:QTMovieLoadStateAttribute]);
    
    if([[self.player attributeForKey:QTMovieLoadStateAttribute] longValue] == QTMovieLoadStatePlaythroughOK)
    {
        NSString *title, *artist = @"", *album;
        NSURL *playingURL = [self.player attributeForKey:@"QTMovieURLAttribute"];
        
        /*
        NSLog(@"%@", self.player);
        NSLog(@"%@", QTStringFromTime(self.player.currentTime));
        
        NSTimeInterval savedTime = [[NSUserDefaults.standardUserDefaults objectForKey:playingURL.absoluteString] doubleValue];
        QTTime time = QTMakeTimeWithTimeInterval(savedTime);
        
        NSLog(@"%f", savedTime);
        NSLog(@"%@", QTStringFromTime(time));
        
        [self.player setCurrentTime:time];
    
        NSLog(@"%@", QTStringFromTime(self.player.currentTime));
        
        //[self.player autoplay];
        
        NSLog(@"%@", QTStringFromTime(self.player.currentTime));
        */
        
        [self updateSlider:nil];
        
        self.albumArtView.image = self.player.posterImage;
        
        /*
         NSLog(@"%@", self.player.commonMetadata);
         NSLog(@"%@", self.player.availableMetadataFormats);
         NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatID3Metadata"]);
         NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatQuickTimeMetadata"]);
         NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatQuickTimeUserData"]);
         NSLog(@"%@", [self.player metadataForFormat:@"QTMetadataFormatiTunesMetadata"]);
         NSLog(@"%@", [self.player metadataForFormat:@"com.apple.quicktime.mdta"]);
         NSLog(@"%@", [self.player metadataForFormat:@"com.apple.quicktime.udta"]);
         */
        
        for(QTMetadataItem *item in self.player.commonMetadata)
        {
            if([(NSString*)item.key isEqualToString:@"title"])
                title = item.stringValue;
            else if([(NSString*)item.key isEqualToString:@"albumName"])
                album = item.stringValue;
            else if([(NSString*)item.key isEqualToString:@"artist"])
                artist = item.stringValue;
        }
        
        title = title ?: playingURL.lastPathComponent;
        album = album ?: playingURL.host;
        
        self.titleLabel.stringValue = title;
        ((SMStatusView*)self.statusItem.view).toolTip = [NSString stringWithFormat:@"PlayBar - %@", title];
        self.albumLabel.stringValue = album;
        self.artistLabel.stringValue = artist;
        
        
        NSInteger rowIndex = 0;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", playingURL];
        NSArray *array = [self.episodes filteredArrayUsingPredicate:predicate];
        
        if(array.count > 0)
        {
            NSString *show = [album isEqualToString:@""] ? artist : album;
            NSDictionary *episodeDictionary = @{ @"title" : title, @"album" : show, @"url" : array[0][@"url"] };
            
            rowIndex = [self.episodes indexOfObject:array[0]];
            [self.episodes replaceObjectAtIndex:rowIndex withObject:episodeDictionary];
            
            [self.episodeList reloadData];
        }
    }
}

- (void)movieRateChanged:(NSNotification*)notification
{
    if(self.player.rate)
    {
        self.playPauseButton.image = [NSImage imageNamed:@"button-pause"];
        SMStatusView *statusView = (SMStatusView*)self.statusItem.view;
        statusView.image = [NSImage imageNamed:@"statusBarIcon-playing"];
        
        [self.timer invalidate];
        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updateSlider:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:(NSString*)kCFRunLoopCommonModes];
    }
    else
    {
        self.playPauseButton.image = [NSImage imageNamed:@"button-play"];
        SMStatusView *statusView = (SMStatusView*)self.statusItem.view;
        statusView.image = [NSImage imageNamed:@"statusBarIcon"];
        
        [self.timer invalidate];
    }
}

- (void)movieEnded:(NSNotification*)notification
{
    [self nextEpisode:nil];
}

- (void)updateSlider:(id)timer
{
    NSTimeInterval currentTime, duration;
    QTGetTimeInterval(self.player.currentTime, &currentTime);
    QTGetTimeInterval(self.player.duration, &duration);
    
    self.seekbar.minValue = 0;
    self.seekbar.floatValue = currentTime;
    self.seekbar.maxValue = duration;
    
    float timeRemaining = duration-currentTime;
    int hours = timeRemaining/60/60;
    int minutes = timeRemaining/60 - 60*hours;
    int seconds = timeRemaining - 60*minutes - 60*60*hours;
    self.timeLabel.stringValue = [NSString stringWithFormat:@"%0.1d:%0.2d:%0.2d", hours, minutes, seconds];
}

#pragma mark - Open Files

- (IBAction)openFileDialog:(id)sender
{
    NSOpenPanel *panel;
    
    panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"mp3"]];
    
    [panel beginSheetModalForWindow:self.popover completionHandler:^(NSInteger result){
        if(result == NSFileHandlingPanelOKButton)
            [self addURL:panel.URL];
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
        [self addURL:[NSURL URLWithString:self.URLField.stringValue]];
}

#pragma mark - Add and Play

- (void)addURL:(NSURL*)url
{
    if(![QTMovie canInitWithURL:url])
        return;
    
    if(self.episodes.count == 0)
        [self playURL:url];
    
    // if is directory, recurse.
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", url];
    NSArray *array = [self.episodes filteredArrayUsingPredicate:predicate];
    
    if(!array || array.count == 0)
    {
        NSDictionary *episodeDictionary = @{ @"title" : url.lastPathComponent, @"album" : url.host, @"url" : url };
        [self.episodes addObject:episodeDictionary];
        [self.episodeList reloadData];
    }
}

- (void)playURL:(NSURL*)url
{
    self.titleLabel.stringValue = @"";
    self.albumLabel.stringValue = @"";
    self.artistLabel.stringValue = @"";
    self.statusItem.toolTip = @"";
    
    self.seekbar.minValue = 0;
    self.seekbar.maxValue = 0;
    self.seekbar.floatValue = 0;
    
    self.albumArtView.image = nil;
    
    NSTimeInterval savedTime = [[NSUserDefaults.standardUserDefaults objectForKey:url.absoluteString] doubleValue];
    QTTime time = QTMakeTimeWithTimeInterval(savedTime);
    
    NSDictionary *attr = @{ QTMovieURLAttribute : url,
                            QTMovieCurrentTimeAttribute : [NSValue valueWithQTTime:time],
                            QTMovieOpenForPlaybackAttribute : @YES
                          };
    
    QTMovie *file = [QTMovie movieWithAttributes:attr error:nil];
    
    //self.player = [[QTMovie alloc] initWithMovie:file timeRange:QTMakeTimeRange(time, time) error:nil];
    
    if(file)
    {
        NSLog(@"%@", QTStringFromTime(time));
        
        self.player = file;
        [self.player setCurrentTime:time];
        [self.player autoplay];
        
        NSLog(@"%@", QTStringFromTime(self.player.currentTime));
    }
}

#pragma mark - Actions

- (IBAction)togglePlayPause:(id)sender
{
    if(self.player.rate)
        [self.player stop];
    else
        [self.player play];
}

- (IBAction)slideSeekbar:(id)sender
{
    self.player.currentTime = QTMakeTimeWithTimeInterval(self.seekbar.floatValue);
    [self updateSlider:nil];
}

- (IBAction)nextEpisode:(id)sender
{
    if(sender)
        [self saveState];
    
    NSURL *playingURL = [self.player attributeForKey:@"QTMovieURLAttribute"];
    NSInteger rowIndex = 0;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", playingURL];
    NSArray *array = [self.episodes filteredArrayUsingPredicate:predicate];
    
    if(array.count > 0)
    {
        rowIndex = [self.episodes indexOfObject:array[0]];
        rowIndex++;
    }
    
    if(!sender && rowIndex >= self.episodes.count)
        [self quit:nil];
    
    if(rowIndex >= self.episodes.count)
        rowIndex = 0;
        
    NSURL *url = self.episodes[rowIndex][@"url"];
    [self playURL:url];
    
    [self.episodeList reloadData];
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

#pragma mark - Helpers

- (void)saveState
{
    NSURL *playingURL = [self.player attributeForKey:@"QTMovieURLAttribute"];
    
    if(playingURL)
    {
        NSTimeInterval currentTime, duration;
        QTGetTimeInterval(self.player.currentTime, &currentTime);
        QTGetTimeInterval(self.player.duration, &duration);
        
        NSLog(@"%f", currentTime);
        NSLog(@"%@", QTStringFromTime(self.player.currentTime));
        
        if(currentTime > duration*0.8f)
            [NSUserDefaults.standardUserDefaults removeObjectForKey:playingURL.absoluteString];
        else
            [NSUserDefaults.standardUserDefaults setObject:@(currentTime) forKey:playingURL.absoluteString];
        
        [NSUserDefaults.standardUserDefaults synchronize];
    }
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
        return self.episodes[rowIndex][@"title"];
    }
    else if([tableColumn.identifier isEqualToString:@"album"])
    {
        return self.episodes[rowIndex][@"album"];
    }
    else if([tableColumn.identifier isEqualToString:@"isPlaying"])
    {
        NSURL *url = self.episodes[rowIndex][@"url"];
        NSURL *playingURL = [self.player attributeForKey:@"QTMovieURLAttribute"];
        
        if([url isEqualTo:playingURL])
            return @"✓";
    }
    
    return nil;
}

- (void)doubleClickOnTableView:(NSTableView*)tableView
{
    [self saveState];
    
    NSURL *url = self.episodes[tableView.clickedRow][@"url"];
    [self playURL:url];
    
    [self.episodeList reloadData];
}

#pragma mark - Window

- (BOOL)togglePopover
{
    NSRect frame = [[[NSApp currentEvent] window] frame];
    NSSize screenSize = self.popover.screen.frame.size;
    
    if(self.popover.isVisible)
    {
        [self.popover close];
        [NSApp deactivate];
    }
    else
    {
        frame.origin.y -= self.popover.frame.size.height;
        frame.origin.x += (frame.size.width - self.popover.frame.size.width)/2;
        
        if(screenSize.width < frame.origin.x + self.popover.frame.size.width)
            frame.origin.x = screenSize.width - self.popover.frame.size.width - 10;
        
        [self.popover setFrameOrigin:frame.origin];
        
        [NSApp activateIgnoringOtherApps:YES];
        [self.popover setIsVisible:YES];
        [self.popover makeKeyAndOrderFront:self];
    }
    
    return self.popover.isVisible;
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self.popover close];
    [((SMStatusView*)self.statusItem.view) highlight:NO];
}

#pragma mark - Kill

- (void)quit:(id)sender
{
    [self.player stop];
    [NSApplication.sharedApplication terminate:self];
}

- (void)applicationWillTerminate:(NSNotification*)notification
{
    [self saveState];
}

@end
