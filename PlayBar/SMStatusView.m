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
    
    isHighlighted = YES;
    [self setNeedsDisplay:YES];
    
    return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    isHighlighted = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    isHighlighted = NO;
    [self setNeedsDisplay:YES];
    
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
            isHighlighted = [self.delegate togglePopover];
        
        isHighlighted = YES;
        [self setNeedsDisplay:YES];
        [self performSelector:@selector(highlight:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1f];
        
        return;
    }
    
    isHighlighted = [self.delegate togglePopover];
    
    [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent*)event
{
    if(isHighlighted)
        isHighlighted = [self.delegate togglePopover];
    
    [self.statusItem.menu setDelegate:self];
    [self.statusItem popUpStatusItemMenu:self.statusItem.menu];
    [self setNeedsDisplay:YES];
}

- (void)otherMouseDown:(NSEvent *)event
{
    if(event.buttonNumber == 2)
    {
        [self.delegate togglePlayPause:nil];
        
        if(isHighlighted)
            isHighlighted = [self.delegate togglePopover];
        
        isHighlighted = YES;
        [self setNeedsDisplay:YES];
        [self performSelector:@selector(highlight:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.1f];
    }
}

- (void)menuWillOpen:(NSMenu*)menu
{
    isHighlighted = YES;
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu*)menu
{
    isHighlighted = NO;
    [self.statusItem.menu setDelegate:nil];
    [self setNeedsDisplay:YES];
}

- (void)highlight:(NSNumber*)_isHightlighted
{
    isHighlighted = _isHightlighted.boolValue;
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
