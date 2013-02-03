//
//  SMStatusView.m
//  PlayBar
//
//  Created by Stuart Moore on 8/12/12.
//
//

#import "SMStatusView.h"

@implementation SMStatusView

@synthesize isHighlighted;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:
                                       NSFilenamesPboardType,
                                       NSURLPboardType,
                                       NSStringPboardType, nil]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    for(NSPasteboardItem *item in sender.draggingPasteboard.pasteboardItems)
    {
        NSURL *url;
        
        if([item.types containsObject:@"public.url"])
            url = [NSURL URLWithString:[item stringForType:@"public.url"]];
        else if([item.types containsObject:@"public.file-url"])
            url = [NSURL URLWithString:[item stringForType:@"public.file-url"]];
        else if([item.types containsObject:@"public.utf8-plain-text"])
            url = [NSURL URLWithString:[item stringForType:@"public.utf8-plain-text"]];
        
        if(![url.pathExtension isEqualToString:@"mp3"] && ![QTMovie canInitWithURL:url])
            return NSDragOperationNone;
    }
    
    [self highlight:YES];
    
    return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    [self highlight:NO];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    [self highlight:NO];
    
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
    
    for(NSURL *url in fileURLs)
        [self.delegate addURL:url];
    
    return YES;
}

- (void)mouseDown:(NSEvent*)event
{
    if(event.modifierFlags & NSControlKeyMask)
    {
        [self rightMouseDown:nil];
        return;
    }
    else if(event.modifierFlags & NSAlternateKeyMask)
    {
        [self.delegate togglePlayPause:nil];
        
        if(isHighlighted)
            [self.delegate togglePopover];
        
        [self highlight:YES];
        [self performSelector:@selector(highlight:) withObject:@NO afterDelay:0.1f];
        
        return;
    }
    
    [self highlight:[self.delegate togglePopover]];
}

- (void)rightMouseDown:(NSEvent*)event
{
    if(isHighlighted)
        [self.delegate togglePopover];
    
    [self.statusItem.menu setDelegate:self];
    [self.statusItem popUpStatusItemMenu:self.statusItem.menu];
}

- (void)otherMouseDown:(NSEvent*)event
{
    if(event.buttonNumber == 2)
    {
        [self.delegate togglePlayPause:nil];
        
        if(isHighlighted)
            [self.delegate togglePopover];
        
        [self highlight:YES];
        [self performSelector:@selector(highlight:) withObject:@NO afterDelay:0.1f];
    }
}

- (void)menuWillOpen:(NSMenu*)menu
{
    [self highlight:YES];
}

- (void)menuDidClose:(NSMenu*)menu
{
    [self highlight:NO];
    [self.statusItem.menu setDelegate:nil];
}

- (void)highlight:(BOOL)_isHightlighted
{
    isHighlighted = _isHightlighted;
    [self setNeedsDisplay:YES];
}

- (void)setImage:(NSImage*)image
{
    _image = image;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
    [self.statusItem drawStatusBarBackgroundInRect:self.bounds withHighlight:isHighlighted];
    
    NSImage *image = isHighlighted?[NSImage imageNamed:@"statusBarIcon-click"]:self.image;
    [image drawInRect:self.bounds fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

@end
