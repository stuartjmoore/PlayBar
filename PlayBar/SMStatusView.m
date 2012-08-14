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
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, NSURLPboardType, NSStringPboardType, nil]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    //NSLog(@"performDragOperation %@",  [[[sender.draggingPasteboard stringForType:@"NSFilenamesPboardType"] propertyList] lastObject]);
   
    NSMutableArray *fileURLs = [NSMutableArray array];
    
    for(NSPasteboardItem *item in sender.draggingPasteboard.pasteboardItems)
    {
        NSURL *url;
        
        if([item.types containsObject:@"public.url"])
            url = [NSURL URLWithString:[item stringForType:@"public.url"]];
        else if([item.types containsObject:@"public.file-url"])
            url = [NSURL URLWithString:[item stringForType:@"public.file-url"]];
        else if([item.types containsObject:@"public.utf8-plain-text"])
            url = [NSURL URLWithString:[item stringForType:@"public.utf8-plain-text"]];
        
        if(url)
            [fileURLs addObject:url];
    }
    
    if(fileURLs.count == 0)
        return NO;
    
    NSLog(@"%@", fileURLs);
    
    for(NSURL *url in fileURLs)
        [self.delegate addURL:url];
    
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
    [[NSColor redColor] setFill];
    NSRectFill(rect);
    
    //[self.statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:isMenuVisible];
}

@end
