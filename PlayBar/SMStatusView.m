//
//  SMStatusView.m
//  PlayBar
//
//  Created by Stuart Moore on 8/12/12.
//
//

#import "SMStatusView.h"

@implementation SMStatusView

@synthesize statusItem = _statusItem, popover = _popover;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSLog(@"draggingEntered %@", sender.draggingPasteboard);
    
    return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    NSLog(@"draggingExited %@", sender.draggingPasteboard);
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    NSLog(@"prepareForDragOperation %@", sender.draggingPasteboard);
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    NSLog(@"performDragOperation %@", sender.draggingPasteboard);
    
    NSLog(@"performDragOperation %@",  [[[sender.draggingPasteboard stringForType:@"NSFilenamesPboardType"] propertyList] lastObject]);
    
    return YES;
}

- (void)mouseDown:(NSEvent*)event
{
    NSRect frame = [[[NSApp currentEvent] window] frame];
    NSSize screenSize = [[self.popover screen] frame].size;
    
    if(self.popover.isVisible)
    {
        isMenuVisible = NO;
        [self.popover close];
    }
    else
    {
        isMenuVisible = YES;
        frame.origin.y -= self.popover.frame.size.height;
        frame.origin.x += (frame.size.width - self.popover.frame.size.width)/2;
        
        if(screenSize.width < frame.origin.x + self.popover.frame.size.width)
            frame.origin.x = screenSize.width - self.popover.frame.size.width - 10;
        
        [self.popover setFrameOrigin:frame.origin];
        
        [self.popover setIsVisible:YES];
        [self.popover makeKeyAndOrderFront:self];
        [self.popover setLevel:NSScreenSaverWindowLevel];
    }
    
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event
{   
    [self.statusItem.menu setDelegate:self];
    [self.statusItem popUpStatusItemMenu:self.statusItem.menu];
    [self setNeedsDisplay:YES];
}

- (void)menuWillOpen:(NSMenu *)menu
{
    isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu
{
    isMenuVisible = NO;
    [self.statusItem.menu setDelegate:nil];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
    [self.statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:isMenuVisible];
    
    [[NSColor redColor] setFill];
    NSRectFill(rect);
}

@end
