//
//  SMAppDelegate.h
//  PlayBar
//
//  Created by Stuart Moore on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "SMStatusView.h"

@interface SMAppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource, SMAppDelegateDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) IBOutlet NSMenu *statusMenu;

@property (strong, nonatomic) IBOutlet NSPanel *popover;
@property (strong, nonatomic) IBOutlet NSTextField *timeLabel;
@property (strong, nonatomic) IBOutlet NSTextField *titleLabel, *albumLabel, *artistLabel;
@property (strong, nonatomic) IBOutlet NSSlider *seekbar;
@property (strong, nonatomic) IBOutlet NSImageView *albumArtView;
@property (strong, nonatomic) IBOutlet NSButton *playPauseButton;

@property (strong, nonatomic) IBOutlet NSTableView *episodeList;

@property (strong, nonatomic) IBOutlet NSWindow *openURLWindow;
@property (strong, nonatomic) IBOutlet NSTextField *URLField;

@property (strong, nonatomic) QTMovie *player;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSMutableArray *episodes;

- (void)movieLoaded:(NSNotification*)notification;
- (void)movieRateChanged:(NSNotification*)notification;
- (void)movieEnded:(NSNotification*)notification;

- (IBAction)openFileDialog:(id)sender;
- (IBAction)openURLDialog:(id)sender;
- (IBAction)closeURLDialog:(NSButton*)sender;

- (void)addURL:(NSURL*)url;
- (void)playURL:(NSURL*)url;

- (IBAction)togglePlayPause:(id)sender;
- (IBAction)slideSeekbar:(id)sender;
- (IBAction)nextEpisode:(id)sender;
- (IBAction)toggleList:(id)sender;

- (void)doubleClickOnTableView:(NSTableView*)tableView;

- (IBAction)quit:(id)sender;

@end
