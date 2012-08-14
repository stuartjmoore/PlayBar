//
//  SMStatusView.h
//  PlayBar
//
//  Created by Stuart Moore on 8/12/12.
//
//

#import <Cocoa/Cocoa.h>

@protocol SMAppDelegateDelegate
@required
- (void)addURL:(NSURL*)url;
- (BOOL)togglePopover;
@end

@interface SMStatusView : NSView <NSMenuDelegate>
{
    BOOL isMenuVisible;
}

@property (nonatomic, weak) id<SMAppDelegateDelegate> delegate;

@property (nonatomic, weak) NSStatusItem *statusItem;

@end
